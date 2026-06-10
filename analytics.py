# -*- coding: utf-8 -*-
"""Modul' analitiki posescheniy: trekkin IP, strany, regiona, brauzer.

Ispol'zuet besplatnoye API ip-api.com (45 zaprosov v minutu, bez klyucha).
Geo-dannye keshiruyutsya v BD chtoby ne dergat' API.
"""
import json
import threading
from datetime import datetime, timedelta
from urllib import request as urlreq
from urllib import error as urlerr
import db


# === Init tablitsy ==========================================================

def init_analytics_tables():
    """Sozdayot tablitsy dlya trekinga posescheniy."""
    conn = db.get_conn()
    c = conn.cursor()
    c.executescript("""
    -- Posescheniya sayta (kazhdyy zapros, krome static i polling)
    CREATE TABLE IF NOT EXISTS visits (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER,           -- NULL = gost'
        ip           TEXT NOT NULL,
        country      TEXT,              -- 'RU', 'UZ', 'US' i t.d.
        country_name TEXT,              -- 'Russia', 'Uzbekistan'
        region       TEXT,              -- oblast'/region
        city         TEXT,
        timezone     TEXT,
        path         TEXT NOT NULL,     -- '/dashboard', '/deck/12'
        method       TEXT DEFAULT 'GET',
        user_agent   TEXT,
        device_type  TEXT,              -- 'mobile', 'tablet', 'desktop', 'bot'
        browser      TEXT,              -- 'Chrome', 'Safari', 'Firefox'
        os           TEXT,              -- 'Windows', 'macOS', 'Android', 'iOS'
        referrer     TEXT,              -- otkuda prishyol
        session_id   TEXT,              -- unikal'nyy id sessii dlya unique visitor
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
    );
    CREATE INDEX IF NOT EXISTS idx_visits_created ON visits(created_at);
    CREATE INDEX IF NOT EXISTS idx_visits_country ON visits(country);
    CREATE INDEX IF NOT EXISTS idx_visits_user ON visits(user_id);
    CREATE INDEX IF NOT EXISTS idx_visits_session ON visits(session_id);
    CREATE INDEX IF NOT EXISTS idx_visits_ip ON visits(ip);

    -- Kesh geo-dannyh po IP (chtoby ne dergat' API kazhdyy raz)
    CREATE TABLE IF NOT EXISTS ip_geo_cache (
        ip           TEXT PRIMARY KEY,
        country      TEXT,
        country_name TEXT,
        region       TEXT,
        city         TEXT,
        timezone     TEXT,
        isp          TEXT,
        cached_at    TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_ip_cache_at ON ip_geo_cache(cached_at);
    """)
    conn.commit()
    conn.close()
    print("[analytics] tables initialized")


# === Geolokatsiya po IP =====================================================

# Lokal'nye / privatnye IP-diapazony (skipnem API zapros)
_PRIVATE_PREFIXES = (
    "10.", "172.16.", "172.17.", "172.18.", "172.19.",
    "172.20.", "172.21.", "172.22.", "172.23.",
    "172.24.", "172.25.", "172.26.", "172.27.",
    "172.28.", "172.29.", "172.30.", "172.31.",
    "192.168.", "127.", "::1", "fe80",
)

# Superadminy isklyuchayutsya iz analitiki
_EXCL_ADMINS = (
    "(user_id IS NULL OR user_id NOT IN "
    "(SELECT id FROM users WHERE username IN ('slezul99@gmail.com','aza')))"
)

# API / XHR vyzovy (vklyuchaya ves' mobilnyy /api/v1/...) — eto ne prosmotry
# stranic. Isklyuchaem ih iz vsekh metrik, chtoby ne razduvat' schyotchiki
# i ne zasoryat' "posledniye posescheniya" sluzhebnymi endpointami.
_NOT_API = "path NOT LIKE '/api/%'"


def is_private_ip(ip: str) -> bool:
    if not ip:
        return True
    return any(ip.startswith(p) for p in _PRIVATE_PREFIXES)


def fetch_geo(ip: str) -> dict:
    """Zapros k ip-api.com (besplatno, 45 RPM, bez klyucha).

    Vozvrashchaet dict s polyami: country, country_name, region, city, timezone, isp.
    Esli oshibka ili privatnyy IP — vozvrashchaet pustye polya.
    """
    if is_private_ip(ip):
        return {
            "country": "LOCAL",
            "country_name": "Local Network",
            "region": "",
            "city": "",
            "timezone": "",
            "isp": "",
        }

    url = f"http://ip-api.com/json/{ip}?fields=status,countryCode,country,regionName,city,timezone,isp"
    try:
        req = urlreq.Request(url, headers={"User-Agent": "QuizAIPro-Analytics/1.0"})
        with urlreq.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        if data.get("status") != "success":
            return {
                "country": "?", "country_name": "Unknown",
                "region": "", "city": "", "timezone": "", "isp": "",
            }
        return {
            "country": data.get("countryCode", "?"),
            "country_name": data.get("country", "Unknown"),
            "region": data.get("regionName", ""),
            "city": data.get("city", ""),
            "timezone": data.get("timezone", ""),
            "isp": data.get("isp", ""),
        }
    except Exception as e:
        print(f"[analytics] geo fetch err for {ip}: {type(e).__name__}: {e}")
        return {
            "country": "?", "country_name": "Unknown",
            "region": "", "city": "", "timezone": "", "isp": "",
        }


# Kesh dlya geo (v pamati, dlya zaprosa pri parallel'nyh hitax na odin IP)
_geo_lock = threading.Lock()
_geo_pending: set[str] = set()  # IP kotorye sejchas obrabatyvayutsya


def get_geo(ip: str) -> dict:
    """Polnyy pipeline: snachala kesh BD, potom API.

    BD-kesh deystvuet 30 dney. Posle istecheniya — obnovlyaem.
    """
    if not ip:
        return {"country": "?", "country_name": "Unknown", "region": "", "city": "", "timezone": "", "isp": ""}

    conn = db.get_conn()
    try:
        # Proveryaem BD-kesh
        row = conn.execute("""
            SELECT country, country_name, region, city, timezone, isp, cached_at
            FROM ip_geo_cache WHERE ip=?
        """, (ip,)).fetchone()
        if row:
            cached_at = row["cached_at"]
            try:
                cached_dt = datetime.fromisoformat(cached_at.replace("T", " ").split(".")[0])
                age_days = (datetime.utcnow() - cached_dt).days
                if age_days < 30:
                    # Svezhiy kesh
                    return dict(row)
            except Exception:
                pass

        # Net keshe ili istek — zaprashivayem API
        with _geo_lock:
            if ip in _geo_pending:
                # Drugoy potok uzhe zaprashivayet — vernyom pustoy stub, on sokhranit
                return {"country": "?", "country_name": "Unknown", "region": "", "city": "", "timezone": "", "isp": ""}
            _geo_pending.add(ip)

        try:
            geo = fetch_geo(ip)
            # Sokhranyaem v kesh
            conn.execute("""
                INSERT OR REPLACE INTO ip_geo_cache
                (ip, country, country_name, region, city, timezone, isp, cached_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                ip, geo["country"], geo["country_name"],
                geo["region"], geo["city"], geo["timezone"], geo["isp"],
                datetime.utcnow().isoformat(),
            ))
            conn.commit()
            return geo
        finally:
            with _geo_lock:
                _geo_pending.discard(ip)
    finally:
        conn.close()


# === User-Agent parsing =====================================================

def parse_user_agent(ua: str) -> dict:
    """Prostoy parser User-Agent — opredelyaet brauzer, OS, tip ustroistva.

    Bez vneshnikh zavisimostey. Ne stol' tochnyy kak ua-parser, no rabotayet."""
    if not ua:
        return {"device_type": "unknown", "browser": "?", "os": "?"}

    ua_lower = ua.lower()

    # Boty
    bot_patterns = ("bot", "crawl", "spider", "scraper", "httrack", "wget", "curl/", "python-requests")
    if any(p in ua_lower for p in bot_patterns):
        return {"device_type": "bot", "browser": "Bot", "os": "Bot"}

    # Tip ustroistva
    if "mobile" in ua_lower or "android" in ua_lower:
        if "tablet" in ua_lower or "ipad" in ua_lower:
            device_type = "tablet"
        else:
            device_type = "mobile"
    elif "ipad" in ua_lower or "tablet" in ua_lower:
        device_type = "tablet"
    else:
        device_type = "desktop"

    # OS
    if "windows" in ua_lower:
        os_name = "Windows"
    elif "android" in ua_lower:
        os_name = "Android"
    elif "iphone" in ua_lower or "ipad" in ua_lower or "ios" in ua_lower:
        os_name = "iOS"
    elif "mac os" in ua_lower or "macintosh" in ua_lower:
        os_name = "macOS"
    elif "linux" in ua_lower:
        os_name = "Linux"
    else:
        os_name = "?"

    # Brauzer (poryadok vazhen — Edge/Opera soderzhat 'Chrome')
    if "edg/" in ua_lower or "edge/" in ua_lower:
        browser = "Edge"
    elif "opr/" in ua_lower or "opera" in ua_lower:
        browser = "Opera"
    elif "yabrowser" in ua_lower:
        browser = "Yandex"
    elif "firefox" in ua_lower:
        browser = "Firefox"
    elif "chrome" in ua_lower:
        browser = "Chrome"
    elif "safari" in ua_lower:
        browser = "Safari"
    else:
        browser = "?"

    return {"device_type": device_type, "browser": browser, "os": os_name}


# === Logirovaniye posescheniy ===============================================

# Asinkhronnaya zapis' — ne blokiruyem zapros polzovatelya
import queue
_visit_queue: queue.Queue = queue.Queue(maxsize=10000)
_worker_started = False
_worker_lock = threading.Lock()


def _visit_worker():
    """Fonovyy potok — pishet visits v BD batchami."""
    while True:
        try:
            batch = []
            # Sobiraem do 50 zapisey ili ozhidaem 5 sekund
            try:
                first = _visit_queue.get(timeout=5)
                batch.append(first)
                while len(batch) < 50:
                    try:
                        batch.append(_visit_queue.get_nowait())
                    except queue.Empty:
                        break
            except queue.Empty:
                continue

            if not batch:
                continue

            # Pishem batchom v BD
            try:
                conn = db.get_conn()
                conn.executemany("""
                    INSERT INTO visits
                    (user_id, ip, country, country_name, region, city, timezone,
                     path, method, user_agent, device_type, browser, os, referrer, session_id)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                """, [
                    (
                        v.get("user_id"), v["ip"],
                        v.get("country", "?"), v.get("country_name", ""),
                        v.get("region", ""), v.get("city", ""), v.get("timezone", ""),
                        v["path"], v.get("method", "GET"),
                        v.get("user_agent", "")[:500], v.get("device_type", ""),
                        v.get("browser", ""), v.get("os", ""),
                        v.get("referrer", "")[:500], v.get("session_id", ""),
                    )
                    for v in batch
                ])
                conn.commit()
                conn.close()
            except Exception as e:
                print(f"[analytics] worker DB err: {type(e).__name__}: {e}")
        except Exception as e:
            print(f"[analytics] worker err: {type(e).__name__}: {e}")


def ensure_worker():
    """Zapuskaem fonovyy potok 1 raz."""
    global _worker_started
    with _worker_lock:
        if _worker_started:
            return
        t = threading.Thread(target=_visit_worker, daemon=True, name="analytics-worker")
        t.start()
        _worker_started = True


def log_visit(user_id, ip, path, method, user_agent, referrer, session_id):
    """Logiruyem posechenie. Zapisyvaet asinkhronno (ne blokiruyem zapros).

    Geo-lookup proishodit v fonovom potoke esli IP eshchyo ne v keshe.
    """
    ensure_worker()

    # Bystryy lookup geo iz keshe (bez API zaprosa)
    geo = {"country": "?", "country_name": "Unknown", "region": "", "city": "", "timezone": "", "isp": ""}
    try:
        conn = db.get_conn()
        row = conn.execute(
            "SELECT country, country_name, region, city, timezone FROM ip_geo_cache WHERE ip=?",
            (ip,)
        ).fetchone()
        conn.close()
        if row:
            geo = dict(row)
        elif is_private_ip(ip):
            geo = {"country": "LOCAL", "country_name": "Local Network", "region": "", "city": "", "timezone": ""}
        else:
            # Net v keshe — zaprashivayem v fone
            threading.Thread(target=get_geo, args=(ip,), daemon=True).start()
    except Exception:
        pass

    ua_data = parse_user_agent(user_agent or "")

    visit = {
        "user_id": user_id,
        "ip": ip,
        "path": path[:500],
        "method": method,
        "user_agent": user_agent or "",
        "referrer": referrer or "",
        "session_id": session_id or "",
        **geo,
        **ua_data,
    }

    try:
        _visit_queue.put_nowait(visit)
    except queue.Full:
        pass  # Esli queue polna — propuskaem (chtoby ne blokirovat')


# === Helpers dlya analitiki =================================================

def get_summary(days: int = 30) -> dict:
    """Obshchaya statistika posescheniy.
    REAL users only: bot trafic + LOCAL ip filtered out (kept as separate counter)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()

    # REAL = ne bot AND ne local IP AND ne superadmin AND ne API-vyzov
    real_filter = f"device_type != 'bot' AND (country IS NULL OR country != 'LOCAL') AND {_EXCL_ADMINS} AND {_NOT_API}"

    stats = {}
    stats["total_visits"] = conn.execute(
        f"SELECT COUNT(*) AS c FROM visits WHERE created_at >= ? AND {real_filter}",
        (cutoff,)
    ).fetchone()["c"]
    stats["unique_visitors"] = conn.execute(
        f"SELECT COUNT(DISTINCT session_id) AS c FROM visits "
        f"WHERE created_at >= ? AND session_id != '' AND {real_filter}",
        (cutoff,)
    ).fetchone()["c"]
    stats["unique_users"] = conn.execute(
        f"SELECT COUNT(DISTINCT user_id) AS c FROM visits "
        f"WHERE created_at >= ? AND user_id IS NOT NULL AND {real_filter}",
        (cutoff,)
    ).fetchone()["c"]
    stats["unique_ips"] = conn.execute(
        f"SELECT COUNT(DISTINCT ip) AS c FROM visits WHERE created_at >= ? AND {real_filter}",
        (cutoff,)
    ).fetchone()["c"]
    stats["bots"] = conn.execute(
        "SELECT COUNT(*) AS c FROM visits WHERE created_at >= ? AND device_type='bot'",
        (cutoff,)
    ).fetchone()["c"]

    conn.close()
    return stats


def get_by_country(days: int = 30, limit: int = 50) -> list[dict]:
    """Top stran (real users only)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute(f"""
        SELECT country, country_name,
            COUNT(*) AS visits,
            COUNT(DISTINCT session_id) AS unique_visitors,
            COUNT(DISTINCT user_id) AS unique_users
        FROM visits
        WHERE created_at >= ? AND country IS NOT NULL AND country != ''
              AND country != 'LOCAL' AND country != '?'
              AND device_type != 'bot' AND {_EXCL_ADMINS} AND {_NOT_API}
        GROUP BY country, country_name
        ORDER BY visits DESC
        LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_by_city(days: int = 30, limit: int = 50) -> list[dict]:
    """Top gorodov (real users only)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute(f"""
        SELECT country, country_name, city,
            COUNT(*) AS visits,
            COUNT(DISTINCT session_id) AS unique_visitors
        FROM visits
        WHERE created_at >= ? AND city IS NOT NULL AND city != ''
              AND country != 'LOCAL' AND country != '?'
              AND device_type != 'bot' AND {_EXCL_ADMINS} AND {_NOT_API}
        GROUP BY country, city
        ORDER BY visits DESC
        LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_daily(days: int = 30) -> list[dict]:
    """Posechenia po dnyam (real users only)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute(f"""
        SELECT DATE(created_at) AS day,
            COUNT(*) AS visits,
            COUNT(DISTINCT session_id) AS unique_visitors,
            COUNT(DISTINCT user_id) AS unique_users
        FROM visits
        WHERE created_at >= ?
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND {_EXCL_ADMINS} AND {_NOT_API}
        GROUP BY DATE(created_at)
        ORDER BY day
    """, (cutoff,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_by_device(days: int = 30) -> list[dict]:
    """Razbivka po tipu ustroistva (real users only — bots excluded)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute("""
        SELECT device_type, COUNT(*) AS visits, COUNT(DISTINCT session_id) AS uniq
        FROM visits
        WHERE created_at >= ? AND device_type IS NOT NULL AND device_type != ''
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY device_type ORDER BY visits DESC
    """, (cutoff,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_by_browser(days: int = 30, limit: int = 10) -> list[dict]:
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute("""
        SELECT browser, COUNT(*) AS visits, COUNT(DISTINCT session_id) AS uniq
        FROM visits
        WHERE created_at >= ? AND browser IS NOT NULL AND browser != ''
              AND browser != 'Bot' AND browser != '?'
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY browser ORDER BY visits DESC LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_by_os(days: int = 30, limit: int = 10) -> list[dict]:
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute("""
        SELECT os, COUNT(*) AS visits, COUNT(DISTINCT session_id) AS uniq
        FROM visits
        WHERE created_at >= ? AND os IS NOT NULL AND os != ''
              AND os != 'Bot' AND os != '?'
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY os ORDER BY visits DESC LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_top_pages(days: int = 30, limit: int = 30) -> list[dict]:
    """Samye populyarnye stranitsy (real users only)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute("""
        SELECT path, COUNT(*) AS visits, COUNT(DISTINCT session_id) AS uniq
        FROM visits
        WHERE created_at >= ?
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY path ORDER BY visits DESC LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_top_referrers(days: int = 30, limit: int = 20) -> list[dict]:
    """Top istochnikov trafika (real users only)."""
    conn = db.get_conn()
    cutoff = (datetime.utcnow() - timedelta(days=days)).isoformat()
    rows = conn.execute("""
        SELECT referrer, COUNT(*) AS visits
        FROM visits
        WHERE created_at >= ? AND referrer IS NOT NULL AND referrer != ''
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY referrer ORDER BY visits DESC LIMIT ?
    """, (cutoff, limit)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_recent_visits(limit: int = 100) -> list[dict]:
    """Posledniye real-user posescheniya (no bots, no LOCAL)."""
    conn = db.get_conn()
    rows = conn.execute("""
        SELECT v.*, u.username
        FROM visits v
        LEFT JOIN users u ON u.id = v.user_id
        WHERE v.device_type != 'bot'
              AND (v.country IS NULL OR v.country != 'LOCAL')
              AND (v.user_id IS NULL OR v.user_id NOT IN (SELECT id FROM users WHERE username IN ('slezul99@gmail.com','aza')))
              AND v.path NOT LIKE '/api/%'
        ORDER BY v.id DESC LIMIT ?
    """, (limit,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def get_hourly_today() -> list[dict]:
    """Posescheniya po chasam za segodnya (real users only)."""
    conn = db.get_conn()
    rows = conn.execute("""
        SELECT strftime('%H', created_at) AS hour,
            COUNT(*) AS visits,
            COUNT(DISTINCT session_id) AS uniq
        FROM visits
        WHERE DATE(created_at) = DATE('now')
              AND device_type != 'bot'
              AND (country IS NULL OR country != 'LOCAL')
              AND path NOT LIKE '/api/%'
        GROUP BY hour ORDER BY hour
    """).fetchall()
    conn.close()
    # Zapolnyaem propuski (chasy bez posescheniy = 0)
    by_hour = {r["hour"]: dict(r) for r in rows}
    result = []
    for h in range(24):
        hh = f"{h:02d}"
        if hh in by_hour:
            result.append(by_hour[hh])
        else:
            result.append({"hour": hh, "visits": 0, "uniq": 0})
    return result
