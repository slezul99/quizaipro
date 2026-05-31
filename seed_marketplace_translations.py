# -*- coding: utf-8 -*-
"""Seed UZ + EN translations for terms-style decks (Phrasal Verbs, IELTS Vocabulary,
Tech Vocab, Marketing, Finance, Accounting, Entrepreneurship).

These decks have:
  front = term in English
  back  = Russian translation
  note  = English explanation

For UZ/EN users, we add proper translations into back_uz / back_en columns,
and clean note for each language.

Safe to re-run: skips cards that already have translations.
"""
import db

conn = db.get_conn()
c = conn.cursor()

# ─── Helper ─────────────────────────────────────────────
def find_card_id(deck_name, front_text):
    """Find card id by deck name + front text."""
    r = c.execute("""
        SELECT c.id FROM cards c
        JOIN decks d ON d.id = c.deck_id
        WHERE d.name = ? AND c.front = ?
        LIMIT 1
    """, (deck_name, front_text)).fetchone()
    return r[0] if r else None

def update_card(card_id, **kwargs):
    """Update card with translation columns."""
    if not card_id: return
    cols = []
    vals = []
    for k, v in kwargs.items():
        cols.append(f"{k}=?")
        vals.append(v)
    vals.append(card_id)
    c.execute(f"UPDATE cards SET {', '.join(cols)} WHERE id = ?", vals)

def add_translations(deck_name, translations):
    """translations = list of (front, back_uz, back_en) tuples."""
    for front, back_uz, back_en in translations:
        cid = find_card_id(deck_name, front)
        if cid:
            update_card(cid, back_uz=back_uz, back_en=back_en)

print("[seed_translations] Starting...")


# ─── Entrepreneurship Glossary ─────────────────────────────
add_translations("Entrepreneurship Glossary", [
    ("MVP", "Minimal hayotchan mahsulot", "Minimum Viable Product"),
    ("Product-Market Fit", "Mahsulot va bozor mosligi", "Product-Market Fit"),
    ("Pivot", "Strategiyani keskin oʻzgartirish", "Strategy pivot"),
    ("Burn rate", "Mablagʻ sarflanish tezligi", "Cash burn rate"),
    ("Runway", "Pul tugamaguncha qolgan vaqt", "Runway (time before cash runs out)"),
    ("Bootstrapping", "Tashqi sarmoyasiz oʻsish", "Bootstrapping (no external investment)"),
    ("Seed round", "Urugʻ raundi (eng erta sarmoya)", "Seed round (earliest funding)"),
    ("Series A / B / C", "A / B / C seriyalari (keyingi raundlar)", "Series A / B / C funding rounds"),
    ("VC (Venture Capital)", "Venchur kapital", "Venture Capital"),
    ("Angel investor", "Biznes-farishta", "Angel investor (early-stage individual)"),
    ("Equity financing", "Aksiyalar orqali sarmoya", "Equity financing (selling shares)"),
    ("Term sheet", "Bitim shartlari hujjati", "Term sheet (deal terms outline)"),
    ("Cap table", "Kapital jadvali", "Cap table (ownership breakdown)"),
    ("Valuation", "Kompaniya bahosi", "Valuation"),
    ("Exit", "Chiqish (sotuv yoki IPO)", "Exit (sale or IPO)"),
    ("IPO", "Birinchi marta ommaviy taklif", "Initial Public Offering"),
    ("Unicorn", "Yakkashox ($1B+ qiymatdagi startup)", "Unicorn (startup valued $1B+)"),
    ("Customer acquisition cost (CAC)", "Mijoz jalb qilish narxi", "Customer Acquisition Cost"),
    ("LTV (Lifetime Value)", "Mijozning butun umri davomidagi qiymati", "Customer Lifetime Value"),
    ("Churn", "Mijozlar oqimi", "Customer churn rate"),
])

# ─── Finance Fundamentals ──────────────────────────────────
add_translations("Finance Fundamentals", [
    ("Asset", "Aktiv (foyda keltiruvchi mulk)", "Asset (resource with economic value)"),
    ("Liability", "Majburiyat (qarz)", "Liability (debt or obligation)"),
    ("Equity", "Kapital (oʻz mablagʻlari)", "Equity (Assets minus Liabilities)"),
    ("Stock / Share", "Aksiya", "Stock (ownership share)"),
    ("Bond", "Obligatsiya", "Bond (debt security)"),
    ("Dividend", "Dividend", "Dividend (profit share)"),
    ("Compound Interest", "Murakkab foiz", "Compound interest (interest on interest)"),
    ("Inflation", "Inflyatsiya", "Inflation (general price rise)"),
    ("Bull market", "Buqa bozori (oʻsuvchi)", "Bull market (rising prices)"),
    ("Bear market", "Ayiq bozori (tushuvchi)", "Bear market (falling prices)"),
    ("Diversification", "Diversifikatsiya", "Diversification (spreading risk)"),
    ("Risk tolerance", "Xavfga chidamlilik", "Risk tolerance"),
    ("Liquidity", "Likvidlik", "Liquidity (ease of converting to cash)"),
    ("Portfolio", "Portfel", "Portfolio (collection of investments)"),
    ("ETF", "Birja-savdo fondi", "Exchange-Traded Fund"),
    ("Mutual fund", "Oʻzaro fond", "Mutual fund (pooled investment)"),
    ("ROI", "Sarmoyadan qaytim (Return on Investment)", "Return on Investment"),
    ("Capital gains", "Aktiv sotishdan daromad", "Capital gains"),
    ("Emergency fund", "Favqulodda holatlar uchun jamgʻarma", "Emergency fund (3-6 months expenses)"),
    ("Net worth", "Sof qiymat", "Net worth (total assets minus liabilities)"),
])

# ─── Accounting Fundamentals ───────────────────────────────
add_translations("Accounting Fundamentals", [
    ("Balance Sheet", "Buxgalteriya balansi", "Balance Sheet"),
    ("Income Statement / P&L", "Foyda va zararlar hisoboti", "Income Statement / P&L"),
    ("Cash Flow Statement", "Pul oqimi hisoboti", "Cash Flow Statement"),
    ("Revenue", "Tushum / daromad", "Revenue (total sales)"),
    ("Expenses", "Xarajatlar", "Expenses (operating costs)"),
    ("Net Income", "Sof foyda", "Net income (after taxes and expenses)"),
    ("Gross Profit", "Yalpi foyda", "Gross profit (revenue minus COGS)"),
    ("COGS", "Sotilgan tovarlar tannarxi", "Cost of Goods Sold"),
    ("Accounts Receivable", "Debitorlik qarzi", "Accounts Receivable (money owed to you)"),
    ("Accounts Payable", "Kreditorlik qarzi", "Accounts Payable (money you owe)"),
    ("Debit", "Debet", "Debit (left side of ledger)"),
    ("Credit", "Kredit", "Credit (right side of ledger)"),
    ("Depreciation", "Amortizatsiya", "Depreciation (asset cost spread over time)"),
    ("Audit", "Audit", "Audit (independent verification)"),
    ("GAAP", "Umumiy qabul qilingan buxgalteriya tamoyillari", "Generally Accepted Accounting Principles"),
    ("Fiscal year", "Moliyaviy yil", "Fiscal year (12-month accounting period)"),
    ("Working capital", "Aylanma mablagʻ", "Working capital (current assets minus current liabilities)"),
    ("EBITDA", "Foiz, soliq, amortizatsiyagacha foyda", "Earnings Before Interest, Taxes, Depreciation, Amortization"),
    ("Equity", "Egalar kapitali", "Equity (owner's claim)"),
    ("Trial balance", "Sinov balansi", "Trial balance (verifies debits = credits)"),
])

# ─── Marketing Fundamentals ────────────────────────────────
add_translations("Marketing Fundamentals", [
    ("Target audience", "Maqsadli auditoriya", "Target audience"),
    ("Brand", "Brend", "Brand (company identity)"),
    ("USP (Unique Selling Proposition)", "Noyob savdo taklifi", "Unique Selling Proposition"),
    ("4P of Marketing", "Marketingning 4P si", "4Ps of Marketing: Product, Price, Place, Promotion"),
    ("Market segmentation", "Bozor segmentatsiyasi", "Market segmentation"),
    ("ROI (Return on Investment)", "Sarmoyadan qaytim", "Return on Investment"),
    ("Conversion rate", "Konversiya darajasi", "Conversion rate"),
    ("CTA (Call to Action)", "Harakatga chaqiruv", "Call to Action"),
    ("SEO (Search Engine Optimization)", "Qidiruv tizimini optimallashtirish", "Search Engine Optimization"),
    ("Content marketing", "Kontent marketing", "Content marketing"),
    ("Funnel", "Sotuvlar voronkasi", "Sales funnel"),
    ("KPI (Key Performance Indicator)", "Asosiy samaradorlik koʻrsatkichi", "Key Performance Indicator"),
    ("B2B", "B2B (biznesdan biznesga)", "Business to Business"),
    ("B2C", "B2C (biznesdan isteʼmolchiga)", "Business to Consumer"),
    ("Churn rate", "Mijozlar oqim foizi", "Churn rate"),
    ("Lifetime value (LTV)", "Mijozning umumiy qiymati", "Customer Lifetime Value"),
    ("A/B testing", "A/B testlash", "A/B testing"),
    ("Organic traffic", "Tabiiy trafik", "Organic traffic (unpaid search visitors)"),
    ("Paid traffic", "Pullik trafik", "Paid traffic (from ads)"),
    ("Engagement rate", "Faollik darajasi", "Engagement rate"),
])

# ─── Technology Vocabulary ─────────────────────────────────
add_translations("Technology Vocabulary", [
    ("software", "dasturiy taʼminot", "Software (apps, programs)"),
    ("hardware", "apparat taʼminot", "Hardware (CPU, RAM, keyboard)"),
    ("to update", "yangilash", "To update (install latest version)"),
    ("to download", "yuklab olish", "To download (get from internet)"),
    ("to upload", "yuklash", "To upload (send to server)"),
    ("password", "parol", "Password (secret access code)"),
    ("username", "foydalanuvchi nomi", "Username (login name)"),
    ("browser", "brauzer", "Browser (Chrome, Firefox, Safari)"),
    ("search engine", "qidiruv tizimi", "Search engine (Google, Yandex)"),
    ("Wi-Fi", "simsiz internet", "Wi-Fi (wireless internet)"),
    ("to charge", "zaryadlash", "To charge (battery)"),
    ("battery", "batareya / akkumulyator", "Battery"),
    ("screen", "ekran", "Screen (display)"),
    ("keyboard", "klaviatura", "Keyboard"),
    ("mouse", "sichqoncha", "Computer mouse"),
    ("cloud storage", "bulutli saqlash", "Cloud storage (Google Drive, iCloud)"),
    ("notification", "bildirishnoma", "Notification (app alert)"),
    ("app / application", "ilova", "Application"),
    ("to crash", "ishdan chiqish", "To crash (app fails)"),
    ("backup", "zaxira nusxa", "Backup (saved copy)"),
])

# ─── IELTS Vocabulary ──────────────────────────────────────
add_translations("IELTS 7.0+ Vocabulary", [
    ("substantial", "salmoqli, sezilarli", "substantial (large, significant)"),
    ("ubiquitous", "hamma joyda mavjud", "ubiquitous (everywhere)"),
    ("plausible", "ishonchli, haqiqatga oʻxshash", "plausible (believable)"),
    ("inevitable", "muqarrar", "inevitable (unavoidable)"),
    ("predominant", "ustun, asosiy", "predominant (main, dominant)"),
    ("comprehensive", "keng qamrovli, toʻliq", "comprehensive (covering everything)"),
    ("controversial", "bahsli, qarama-qarshi", "controversial (causing debate)"),
    ("significant", "muhim, sezilarli", "significant (important)"),
    ("crucial", "juda muhim", "crucial (extremely important)"),
    ("emerge", "paydo boʻlmoq", "emerge (appear, come out)"),
    ("derive (from)", "kelib chiqmoq", "derive from (originate)"),
    ("undermine", "puchga chiqarmoq", "undermine (weaken)"),
    ("reinforce", "mustahkamlamoq", "reinforce (strengthen)"),
    ("alleviate", "yumshatmoq, yengilatish", "alleviate (relieve)"),
    ("exacerbate", "yomonlashtirmoq", "exacerbate (make worse)"),
    ("compelling", "ishontiruvchi", "compelling (convincing)"),
    ("scrutiny", "diqqat bilan oʻrganish", "scrutiny (close examination)"),
    ("inherent", "ichki, tabiiy", "inherent (natural part of)"),
    ("sustainable", "barqaror", "sustainable (long-lasting)"),
    ("paradigm", "paradigma, namuna", "paradigm (model, pattern)"),
])

# ─── Phrasal Verbs ─────────────────────────────────────────
add_translations("Top 20 Phrasal Verbs", [
    ("give up", "taslim boʻlmoq / tashlamoq", "to give up / quit"),
    ("look after", "qaramoq, gʻamxoʻrlik qilmoq", "to look after / take care of"),
    ("look for", "qidirmoq", "to look for / search"),
    ("turn on / off", "yoqmoq / oʻchirmoq", "to turn on / off"),
    ("get up", "(yotoqdan) turmoq", "to get up (from bed)"),
    ("get on (with)", "kelishib yashamoq", "to get along with"),
    ("put on", "kiyib olmoq", "to put on (clothes)"),
    ("take off", "yechmoq / uchmoq", "to take off (clothes / plane departs)"),
    ("come back", "qaytib kelmoq", "to come back / return"),
    ("go on", "davom etmoq / sodir boʻlmoq", "to go on / continue / happen"),
    ("find out", "bilib olmoq", "to find out / discover"),
    ("run out (of)", "tugamoq", "to run out of (be empty)"),
    ("break down", "buzilmoq (mashina, odam)", "to break down (car, person)"),
    ("hang out", "vaqt oʻtkazmoq", "to hang out / spend time"),
    ("show up", "kelmoq, paydo boʻlmoq", "to show up / appear"),
    ("set up", "tashkil qilmoq / oʻrnatmoq", "to set up / establish"),
    ("work out", "shugʻullanmoq / hal boʻlmoq", "to work out / exercise / succeed"),
    ("calm down", "tinchlanmoq", "to calm down / relax"),
    ("look up", "qidirmoq (lugʻatda)", "to look up (in dictionary)"),
    ("go through", "boshdan kechirmoq", "to go through (experience)"),
])

conn.commit()
conn.close()
print("[seed_translations] Done — added UZ + EN translations for ~140 cards")
