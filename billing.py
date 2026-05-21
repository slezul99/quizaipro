# -*- coding: utf-8 -*-
"""Stripe billing - checkout session, webhook, plans tracking v DB."""
from datetime import datetime
import db
import config


def init_billing_tables():
    """Sozdayot tablitsy dlya tracking podpisok."""
    conn = db.get_conn()
    conn.executescript("""
    CREATE TABLE IF NOT EXISTS subscriptions (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id         INTEGER,
        org_id          INTEGER,
        plan            TEXT NOT NULL,           -- free / pro_individual / team / school
        status          TEXT NOT NULL,           -- active / canceled / past_due
        stripe_customer_id    TEXT,
        stripe_subscription_id TEXT,
        current_period_end TEXT,
        created_at      TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at      TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(org_id) REFERENCES organizations(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_subs_user ON subscriptions(user_id);
    CREATE INDEX IF NOT EXISTS idx_subs_org ON subscriptions(org_id);

    CREATE TABLE IF NOT EXISTS ai_usage (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id         INTEGER,
        org_id          INTEGER,
        kind            TEXT NOT NULL,    -- text/topic/pdf
        cards_generated INTEGER DEFAULT 0,
        created_at      TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_ai_user ON ai_usage(user_id, created_at);
    CREATE INDEX IF NOT EXISTS idx_ai_org ON ai_usage(org_id, created_at);
    """)
    conn.commit(); conn.close()


def get_active_plan(user: dict) -> str:
    """Vozvraschayet imya tekushchego plana."""
    if not user:
        return "free"
    conn = db.get_conn()
    if user.get("org_id"):
        sub = conn.execute("""SELECT plan FROM subscriptions
                              WHERE org_id=? AND status='active'
                              ORDER BY id DESC LIMIT 1""", (user["org_id"],)).fetchone()
    else:
        sub = conn.execute("""SELECT plan FROM subscriptions
                              WHERE user_id=? AND status='active'
                              ORDER BY id DESC LIMIT 1""", (user["id"],)).fetchone()
    conn.close()
    return sub["plan"] if sub else "free"


def check_ai_limit(user: dict) -> tuple[bool, int, int]:
    """Vozvraschayet (mozhno_li, ispol'zovano_v_mes, limit).
    Esli u polzovatelya zadan kastomnyy lim (ai_limit_monthly) — beryom ego."""
    # Super-admin = bezlimit (proverim po hardcoded usernames v app.py)
    # Beta-tester ili kastomnyy ai_limit_monthly perekrivayet plan
    custom_monthly = user.get("ai_limit_monthly") if user else None
    custom_daily = user.get("ai_limit_daily") if user else None
    is_beta = user.get("is_beta_tester") if user else False

    plan = get_active_plan(user)
    plan_limit = config.PLANS[plan]["limits"]["ai_generations_per_month"]

    conn = db.get_conn()
    month_start = datetime.utcnow().replace(day=1, hour=0, minute=0, second=0).isoformat()
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0).isoformat()

    if user.get("org_id"):
        used_month = conn.execute("""SELECT COUNT(*) AS c FROM ai_usage
                               WHERE org_id=? AND created_at >= ?""",
                            (user["org_id"], month_start)).fetchone()["c"]
        used_today = conn.execute("""SELECT COUNT(*) AS c FROM ai_usage
                               WHERE org_id=? AND created_at >= ?""",
                            (user["org_id"], today_start)).fetchone()["c"]
    else:
        used_month = conn.execute("""SELECT COUNT(*) AS c FROM ai_usage
                               WHERE user_id=? AND created_at >= ?""",
                            (user["id"], month_start)).fetchone()["c"]
        used_today = conn.execute("""SELECT COUNT(*) AS c FROM ai_usage
                               WHERE user_id=? AND created_at >= ?""",
                            (user["id"], today_start)).fetchone()["c"]
    conn.close()

    # Daily lim (esli zadan)
    if custom_daily is not None:
        if used_today >= custom_daily:
            return (False, used_month, custom_monthly if custom_monthly is not None else plan_limit)

    # Monthly: prioritet u kastomnogo lim'a
    if custom_monthly is not None:
        return (used_month < custom_monthly, used_month, custom_monthly)

    # Beta-tester (esli kastomnogo lim'a net) = bezlimit
    if is_beta:
        return (True, used_month, 99999)

    # Default — po planu
    return (used_month < plan_limit, used_month, plan_limit)


def log_ai_usage(user: dict, kind: str, cards: int = 0):
    conn = db.get_conn()
    conn.execute("""INSERT INTO ai_usage (user_id, org_id, kind, cards_generated)
                    VALUES (?, ?, ?, ?)""",
                 (user.get("id") if user.get("role") == "individual" else None,
                  user.get("org_id"), kind, cards))
    conn.commit(); conn.close()


def create_checkout_session(user: dict, plan: str, success_url: str, cancel_url: str):
    """Sozdayet Stripe checkout session, vozvraschayet URL."""
    if not config.has_stripe():
        return None
    if plan not in config.PLANS or plan == "free":
        return None
    price_id = config.PLANS[plan]["stripe_price_id"]
    if not price_id:
        return None
    try:
        import stripe
        stripe.api_key = config.STRIPE_SECRET_KEY
        sub_type = "team" if plan in ("team", "school") else "individual"
        meta = {"plan": plan, "user_id": user["id"]}
        if user.get("org_id"):
            meta["org_id"] = user["org_id"]
        sess = stripe.checkout.Session.create(
            mode="subscription",
            line_items=[{"price": price_id, "quantity": 1}],
            success_url=success_url,
            cancel_url=cancel_url,
            client_reference_id=str(user["id"]),
            metadata=meta,
        )
        return sess.url
    except Exception as e:
        print(f"[STRIPE] {type(e).__name__}: {e}")
        return None


def handle_webhook(payload: bytes, sig_header: str) -> bool:
    """Obrabotka Stripe webhook events."""
    if not config.has_stripe() or not config.STRIPE_WEBHOOK_SECRET:
        return False
    try:
        import stripe
        stripe.api_key = config.STRIPE_SECRET_KEY
        event = stripe.Webhook.construct_event(
            payload, sig_header, config.STRIPE_WEBHOOK_SECRET
        )
    except Exception as e:
        print(f"[STRIPE WH] verify error: {e}")
        return False

    obj = event["data"]["object"]
    etype = event["type"]

    conn = db.get_conn()
    try:
        if etype == "checkout.session.completed":
            meta = obj.get("metadata", {})
            user_id = int(meta.get("user_id", 0))
            org_id = int(meta.get("org_id", 0)) if meta.get("org_id") else None
            plan = meta.get("plan", "")
            customer = obj.get("customer", "")
            subscription = obj.get("subscription", "")
            conn.execute("""INSERT INTO subscriptions
                (user_id, org_id, plan, status, stripe_customer_id, stripe_subscription_id)
                VALUES (?, ?, ?, 'active', ?, ?)""",
                (user_id if not org_id else None, org_id, plan, customer, subscription))
            conn.commit()

        elif etype in ("customer.subscription.deleted", "customer.subscription.updated"):
            sub_id = obj.get("id")
            new_status = obj.get("status", "canceled")
            if etype == "customer.subscription.deleted":
                new_status = "canceled"
            conn.execute("""UPDATE subscriptions SET status=?, updated_at=CURRENT_TIMESTAMP
                            WHERE stripe_subscription_id=?""", (new_status, sub_id))
            conn.commit()
    except Exception as e:
        print(f"[STRIPE WH] {type(e).__name__}: {e}")
        conn.close()
        return False
    conn.close()
    return True
