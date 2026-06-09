#!/usr/bin/env bash
# Verification smoke test for Phase 3: deck cards / study grade / study sessions
# Usage: bash api_v1/test_phase3_study.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5055}"
EMAIL="qa3_$(date +%s)@example.com"
PASSWORD="TestPass123"

pass=0
fail=0

check() {
  local name="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    echo "  [PASS] $name (got $actual)"
    pass=$((pass+1))
  else
    echo "  [FAIL] $name (expected $expected, got $actual)"
    fail=$((fail+1))
  fi
}

jget() { python -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null; }
nowiso() { python -c "import datetime;print(datetime.datetime.utcnow().isoformat()+'Z')"; }
futureiso() { python -c "import datetime;print((datetime.datetime.utcnow()+datetime.timedelta(days=$1)).isoformat()+'Z')"; }

echo "=== 0. Register fresh QA user, get bearer token ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qa3tester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
check "setup: register status" "201" "$REG_CODE"
ACCESS=$(echo "$REG_BODY" | jget "d['data']['access_token']")
AUTH="Authorization: Bearer $ACCESS"
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS})" || echo "  [FAIL] no access_token"

echo ""
echo "=== 0b. Create a deck + card directly (so we have something to study) ==="
python - "$BASE" "$EMAIL" <<'PYEOF'
import sys, sqlite3, datetime
db_path = "quizpro.db"
conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row
email = sys.argv[2]
user = conn.execute("SELECT id FROM users WHERE username=?", (email,)).fetchone()
if user is None:
    print("NO_USER"); sys.exit(0)
uid = user["id"]
cur = conn.execute("INSERT INTO decks (owner_id, name, description, is_public) VALUES (?, 'QA Deck', 'qa', 0)", (uid,))
deck_id = cur.lastrowid
cur = conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, 'Q1', 'A1', 'hint1')", (deck_id,))
card_id = cur.lastrowid
conn.commit()
print(f"DECK_ID={deck_id}")
print(f"CARD_ID={card_id}")
PYEOF

SETUP=$(python - "$EMAIL" <<'PYEOF'
import sys, sqlite3
conn = sqlite3.connect("quizpro.db")
conn.row_factory = sqlite3.Row
email = sys.argv[1]
user = conn.execute("SELECT id FROM users WHERE username=?", (email,)).fetchone()
uid = user["id"]
deck = conn.execute("SELECT id FROM decks WHERE owner_id=? ORDER BY id DESC LIMIT 1", (uid,)).fetchone()
card = conn.execute("SELECT id FROM cards WHERE deck_id=? ORDER BY id DESC LIMIT 1", (deck["id"],)).fetchone()
print(f"{deck['id']} {card['id']}")
PYEOF
)
DECK_ID=$(echo "$SETUP" | awk '{print $1}')
CARD_ID=$(echo "$SETUP" | awk '{print $2}')
echo "  -> deck_id=$DECK_ID card_id=$CARD_ID"

echo ""
echo "=== 1. GET /api/v1/decks/<id>/cards ==="
DC=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/decks/$DECK_ID/cards" -H "$AUTH")
DC_BODY=$(echo "$DC" | head -n -1)
DC_CODE=$(echo "$DC" | tail -n1)
check "deck cards status" "200" "$DC_CODE"
check "deck cards is a list" "list" "$(echo "$DC_BODY" | jget "type(d['data']).__name__")"
check "first card id matches" "$CARD_ID" "$(echo "$DC_BODY" | jget "d['data'][0]['id']")"
check "first card has snake_case fields" "True" "$(echo "$DC_BODY" | jget "set(['id','deck_id','front','back','hint','ease_factor','interval','repetitions','next_review_at','last_studied_at','is_favorite','is_difficult','again_count','updated_at']) <= set(d['data'][0].keys())")"
check "new card ease_factor default" "2.5" "$(echo "$DC_BODY" | jget "d['data'][0]['ease_factor']")"
check "new card repetitions default" "0" "$(echo "$DC_BODY" | jget "d['data'][0]['repetitions']")"

echo ""
echo "=== 2. GET /api/v1/decks/<id>/cards (no token -> 401) ==="
NOAUTH=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/decks/$DECK_ID/cards")
check "deck cards without token status" "401" "$NOAUTH"

echo ""
echo "=== 3. POST /api/v1/study/grade (valid 'good' grade) ==="
GRADED_AT=$(nowiso)
NEXT_AT=$(futureiso 6)
G1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"$CARD_ID\",\"deck_id\":\"$DECK_ID\",\"grade\":4,\"new_ease_factor\":2.5,\"new_interval\":6,\"new_repetitions\":2,\"next_review_at\":\"$NEXT_AT\",\"graded_at\":\"$GRADED_AT\"}")
G1_BODY=$(echo "$G1" | head -n -1)
G1_CODE=$(echo "$G1" | tail -n1)
echo "$G1_BODY" | python -m json.tool 2>/dev/null
check "grade status" "200" "$G1_CODE"
check "grade persisted ease_factor" "2.5" "$(echo "$G1_BODY" | jget "d['data']['ease_factor']")"
check "grade persisted interval_days" "6" "$(echo "$G1_BODY" | jget "d['data']['interval_days']")"
check "grade persisted repetitions" "2" "$(echo "$G1_BODY" | jget "d['data']['repetitions']")"
check "grade xp_gained for 'good'" "3" "$(echo "$G1_BODY" | jget "d['data']['xp_gained']")"
check "grade not already_applied (first time)" "False" "$(echo "$G1_BODY" | jget "d['data']['already_applied']")"

echo ""
echo "=== 4. POST /api/v1/study/grade — RETRY same graded_at (idempotency) ==="
G2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"$CARD_ID\",\"deck_id\":\"$DECK_ID\",\"grade\":4,\"new_ease_factor\":2.5,\"new_interval\":6,\"new_repetitions\":2,\"next_review_at\":\"$NEXT_AT\",\"graded_at\":\"$GRADED_AT\"}")
G2_BODY=$(echo "$G2" | head -n -1)
G2_CODE=$(echo "$G2" | tail -n1)
check "retry grade status" "200" "$G2_CODE"
check "retry grade already_applied=True" "True" "$(echo "$G2_BODY" | jget "d['data']['already_applied']")"
check "retry grade xp_gained=0 (no double apply)" "0" "$(echo "$G2_BODY" | jget "d['data']['xp_gained']")"

echo ""
echo "=== 5. POST /api/v1/study/grade — validation: bad grade value ==="
BG=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"$CARD_ID\",\"deck_id\":\"$DECK_ID\",\"grade\":2,\"new_ease_factor\":2.5,\"new_interval\":6,\"new_repetitions\":2,\"next_review_at\":\"$NEXT_AT\",\"graded_at\":\"$(nowiso)\"}")
check "invalid grade -> 400" "400" "$BG"

echo ""
echo "=== 6. POST /api/v1/study/grade — validation: EF out of range ==="
BEF=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"$CARD_ID\",\"deck_id\":\"$DECK_ID\",\"grade\":4,\"new_ease_factor\":9.9,\"new_interval\":6,\"new_repetitions\":2,\"next_review_at\":\"$NEXT_AT\",\"graded_at\":\"$(nowiso)\"}")
check "EF out of range -> 400" "400" "$BEF"

echo ""
echo "=== 7. POST /api/v1/study/grade — validation: again-grade with nonzero repetitions ==="
BAR=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"$CARD_ID\",\"deck_id\":\"$DECK_ID\",\"grade\":1,\"new_ease_factor\":2.0,\"new_interval\":1,\"new_repetitions\":3,\"next_review_at\":\"$(futureiso 1)\",\"graded_at\":\"$(nowiso)\"}")
check "again grade w/ nonzero repetitions -> 400" "400" "$BAR"

echo ""
echo "=== 8. POST /api/v1/study/grade — non-existent card -> 404 ==="
NF=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/grade" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"card_id\":\"99999999\",\"deck_id\":\"$DECK_ID\",\"grade\":4,\"new_ease_factor\":2.5,\"new_interval\":6,\"new_repetitions\":2,\"next_review_at\":\"$NEXT_AT\",\"graded_at\":\"$(nowiso)\"}")
check "grade for missing card -> 404" "404" "$NF"

echo ""
echo "=== 9. GET /api/v1/decks/<id>/cards reflects persisted grade ==="
DC2=$(curl -s "$BASE/api/v1/decks/$DECK_ID/cards" -H "$AUTH")
check "card now shows repetitions=2" "2" "$(echo "$DC2" | jget "d['data'][0]['repetitions']")"
check "card now shows again_count=0" "0" "$(echo "$DC2" | jget "d['data'][0]['again_count']")"
check "card now shows ease_factor=2.5" "2.5" "$(echo "$DC2" | jget "d['data'][0]['ease_factor']")"

echo ""
echo "=== 10. POST /api/v1/study/sessions ==="
SID="qa-session-$(date +%s)"
COMPLETED=$(nowiso)
S1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/study/sessions" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$SID\",\"deck_id\":\"$DECK_ID\",\"total_cards\":5,\"new_cards\":3,\"review_cards\":2,\"again_count\":1,\"hard_count\":1,\"good_count\":2,\"easy_count\":1,\"duration_seconds\":120,\"completed_at\":\"$COMPLETED\"}")
S1_BODY=$(echo "$S1" | head -n -1)
S1_CODE=$(echo "$S1" | tail -n1)
check "create session status" "201" "$S1_CODE"
check "session id echoed" "$SID" "$(echo "$S1_BODY" | jget "d['data']['id']")"
check "session total_cards" "5" "$(echo "$S1_BODY" | jget "d['data']['total_cards']")"

echo ""
echo "=== 11. POST /api/v1/study/sessions — retry same id (idempotency) ==="
S2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/study/sessions" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$SID\",\"deck_id\":\"$DECK_ID\",\"total_cards\":999,\"new_cards\":3,\"review_cards\":2,\"again_count\":1,\"hard_count\":1,\"good_count\":2,\"easy_count\":1,\"duration_seconds\":120,\"completed_at\":\"$COMPLETED\"}")
S2_BODY=$(echo "$S2" | head -n -1)
check "retry session keeps original total_cards (idempotent)" "5" "$(echo "$S2_BODY" | jget "d['data']['total_cards']")"

echo ""
echo "=== 12. GET /api/v1/study/sessions/<id> ==="
GS=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/study/sessions/$SID" -H "$AUTH")
GS_BODY=$(echo "$GS" | head -n -1)
GS_CODE=$(echo "$GS" | tail -n1)
check "get session status" "200" "$GS_CODE"
check "get session id matches" "$SID" "$(echo "$GS_BODY" | jget "d['data']['id']")"

echo ""
echo "=== 13. GET /api/v1/study/sessions/<id> — non-existent -> 404 ==="
NFS=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/study/sessions/does-not-exist" -H "$AUTH")
check "missing session -> 404" "404" "$NFS"

echo ""
echo "=== 14. Auth required on all new endpoints (401) ==="
for path in "/api/v1/decks/$DECK_ID/cards" "/api/v1/study/sessions/$SID"; do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$path")
  check "no-token 401: $path" "401" "$CODE"
done
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/grade" -H 'Content-Type: application/json' -d '{}')
check "no-token 401: POST /api/v1/study/grade" "401" "$CODE"
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/study/sessions" -H 'Content-Type: application/json' -d '{}')
check "no-token 401: POST /api/v1/study/sessions" "401" "$CODE"

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
