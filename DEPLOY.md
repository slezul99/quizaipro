# Deploy QuizPro na Render.com (besplatno)

## 1. Google OAuth setup

1. https://console.cloud.google.com → APIs & Services → Credentials
2. Create credentials → OAuth client ID → Web application
3. Authorized redirect URIs:
   - `http://localhost:5000/auth/google/callback` (dlya testa)
   - `https://YOUR-APP.onrender.com/auth/google/callback` (posle deploy)
4. Skopiruy Client ID i Client Secret
5. Sozday `google_oauth.txt` v korne, 2 stroki:
```
твой_client_id
твой_client_secret
```

## 2. Stripe setup

1. https://dashboard.stripe.com → API keys
2. Skopiruy Publishable + Secret keys
3. Sozday produkty: Pro Individual ($9), Team ($49), School ($149) — po podpiske mes.
4. Vozm Price ID-y dlya kazhdogo
5. Sozday `stripe_keys.txt`:
```
pk_test_...
sk_test_...
```

## 3. Deploy na Render.com

1. Push proekt na GitHub (private repo OK)
2. https://dashboard.render.com → New → Web Service
3. Connect repo, vyberi `quizpro`
4. Render avtomaticheski uvidit `render.yaml` i `requirements.txt`
5. Environment Variables (Settings → Environment):
   - `GOOGLE_CLIENT_ID` = ...
   - `GOOGLE_CLIENT_SECRET` = ...
   - `STRIPE_PUBLISHABLE_KEY` = ...
   - `STRIPE_SECRET_KEY` = ...
   - `STRIPE_WEBHOOK_SECRET` = (poluchish' posle nastroyki webhook)
   - `STRIPE_PRICE_PRO_IND` = price_...
   - `STRIPE_PRICE_TEAM` = price_...
   - `STRIPE_PRICE_SCHOOL` = price_...
   - `GEMINI_API_KEY` = ... (ili polozhi gemini_key.txt v repo)
6. Deploy. Cherez 3-5 min — sayt na `https://quizpro-XXXX.onrender.com`

## 4. Stripe webhook

1. Stripe Dashboard → Webhooks → Add endpoint
2. URL: `https://YOUR-APP.onrender.com/billing/webhook`
3. Events: `checkout.session.completed`, `customer.subscription.deleted`, `customer.subscription.updated`
4. Skopiruy signing secret → STRIPE_WEBHOOK_SECRET

## 5. Vazhno

- **Render free tier** zasypaet posle 15 min nepol'zovaniya. Pervyy zapros pridyot za 30 sek.
- **SQLite na Render free** — fayl ezhednevno mozhet sbros'evat'sya. Dlya production nuzhna PostgreSQL ($7/mes).
- **Custom domen** — v Render Settings → Custom Domain, $0.
