#!/usr/bin/env bash
# Verification smoke test for Phase 4: test questions / results / history
# Usage: bash api_v1/test_phase4_tests.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5000}"
EMAIL="qa4_$(date +%s)@example.com"
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

echo "=== 0. Register fresh QA user, get bearer token ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qa4tester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
check "setup: register status" "201" "$REG_CODE"
ACCESS=$(echo "$REG_BODY" | jget "d['data']['access_token']")
AUTH="Authorization: Bearer $ACCESS"
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS})" || echo "  [FAIL] no access_token"

echo ""
echo "=== 0b. Create a deck with MCQ cards + a plain (non-MCQ) card ==="
SETUP=$(python - "$EMAIL" <<'PYEOF'
import sys, sqlite3
conn = sqlite3.connect("quizpro.db")
conn.row_factory = sqlite3.Row
email = sys.argv[1]
user = conn.execute("SELECT id FROM users WHERE username=?", (email,)).fetchone()
uid = user["id"]
cur = conn.execute("INSERT INTO decks (owner_id, name, description, is_public) VALUES (?, 'QA4 Test Deck', 'qa4', 0)", (uid,))
deck_id = cur.lastrowid
# MCQ card 1: correct = B
conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, 'Capital of France?', 'B) Paris', 'A) London\nB) Paris\nC) Berlin\nD) Madrid')", (deck_id,))
# MCQ card 2: correct = A
conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, '2 + 2 = ?', 'A) 4', 'A) 4\nB) 5\nC) 22\nD) 3')", (deck_id,))
# Plain non-MCQ card (term/definition) — should be excluded from test-questions
conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, 'Photosynthesis', 'Process plants use to convert light into energy', '')", (deck_id,))
conn.commit()
print(f"DECK_ID={deck_id}")
PYEOF
)
DECK_ID=$(echo "$SETUP" | grep DECK_ID | cut -d= -f2)
echo "  -> deck_id=$DECK_ID"

echo ""
echo "=== 1. GET /api/v1/decks/<id>/test-questions ==="
TQ=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/decks/$DECK_ID/test-questions" -H "$AUTH")
TQ_BODY=$(echo "$TQ" | head -n -1)
TQ_CODE=$(echo "$TQ" | tail -n1)
echo "$TQ_BODY" | python -m json.tool 2>/dev/null
check "test-questions status" "200" "$TQ_CODE"
check "test-questions count (MCQ-only, plain card excluded)" "2" "$(echo "$TQ_BODY" | jget "len(d['data'])")"
check "question has snake_case shape" "True" "$(echo "$TQ_BODY" | jget "set(['id','deck_id','question','correct_answer','options','topic']) <= set(d['data'][0].keys())")"
check "options have id/text/is_correct" "True" "$(echo "$TQ_BODY" | jget "set(['id','text','is_correct']) <= set(d['data'][0]['options'][0].keys())")"
check "exactly one option marked correct" "True" "$(echo "$TQ_BODY" | jget "all(sum(1 for o in q['options'] if o['is_correct'])==1 for q in d['data'])")"
check "correct_answer matches the correct option's text" "True" "$(echo "$TQ_BODY" | jget "all(q['correct_answer']==[o['text'] for o in q['options'] if o['is_correct']][0] for q in d['data'])")"
check "deck_id is a string" "True" "$(echo "$TQ_BODY" | jget "isinstance(d['data'][0]['deck_id'], str)")"

echo ""
echo "=== 2. GET /api/v1/decks/<id>/test-questions (no token -> 401) ==="
NOAUTH=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/decks/$DECK_ID/test-questions")
check "test-questions without token status" "401" "$NOAUTH"

echo ""
echo "=== 3. GET /api/v1/decks/<id>/test-questions (non-existent deck -> 404) ==="
NF404=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/decks/9999999/test-questions" -H "$AUTH")
check "missing deck -> 404" "404" "$NF404"

echo ""
echo "=== 4. POST /api/v1/test/results ==="
RID="qa4-$(python -c "import uuid;print(uuid.uuid4().hex)")"
COMPLETED=$(nowiso)
R1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/test/results" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$RID\",\"deck_id\":\"$DECK_ID\",\"total_questions\":2,\"correct_count\":2,\"duration_seconds\":90,\"completed_at\":\"$COMPLETED\"}")
R1_BODY=$(echo "$R1" | head -n -1)
R1_CODE=$(echo "$R1" | tail -n1)
echo "$R1_BODY" | python -m json.tool 2>/dev/null
check "submit result status" "201" "$R1_CODE"
check "result id echoed" "$RID" "$(echo "$R1_BODY" | jget "d['data']['id']")"
check "result deck_id" "$DECK_ID" "$(echo "$R1_BODY" | jget "d['data']['deck_id']")"
check "result deck_title" "QA4 Test Deck" "$(echo "$R1_BODY" | jget "d['data']['deck_title']")"
check "result total_questions" "2" "$(echo "$R1_BODY" | jget "d['data']['total_questions']")"
check "result correct_count" "2" "$(echo "$R1_BODY" | jget "d['data']['correct_count']")"
check "result duration_seconds" "90" "$(echo "$R1_BODY" | jget "d['data']['duration_seconds']")"

echo ""
echo "=== 5. POST /api/v1/test/results — retry same id (idempotency) ==="
R2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/test/results" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$RID\",\"deck_id\":\"$DECK_ID\",\"total_questions\":999,\"correct_count\":999,\"duration_seconds\":1,\"completed_at\":\"$COMPLETED\"}")
R2_BODY=$(echo "$R2" | head -n -1)
check "retry result keeps original total_questions (idempotent)" "2" "$(echo "$R2_BODY" | jget "d['data']['total_questions']")"
check "retry result keeps original correct_count (idempotent)" "2" "$(echo "$R2_BODY" | jget "d['data']['correct_count']")"

echo ""
echo "=== 6. POST /api/v1/test/results — validation: correct_count > total_questions ==="
BV=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/test/results" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"qa4-bad-$(date +%s)\",\"deck_id\":\"$DECK_ID\",\"total_questions\":1,\"correct_count\":5,\"duration_seconds\":10,\"completed_at\":\"$(nowiso)\"}")
check "correct_count > total -> 400" "400" "$BV"

echo ""
echo "=== 7. POST /api/v1/test/results — non-existent deck -> 404 ==="
NF=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/test/results" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"qa4-nf-$(date +%s)\",\"deck_id\":\"9999999\",\"total_questions\":1,\"correct_count\":1,\"duration_seconds\":10,\"completed_at\":\"$(nowiso)\"}")
check "result for missing deck -> 404" "404" "$NF"

echo ""
echo "=== 8. Submit a second (imperfect) result for history ordering ==="
RID2="qa4-$(python -c "import uuid;print(uuid.uuid4().hex)")"
sleep 1
COMPLETED2=$(nowiso)
curl -s -o /dev/null -X POST "$BASE/api/v1/test/results" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$RID2\",\"deck_id\":\"$DECK_ID\",\"total_questions\":2,\"correct_count\":1,\"duration_seconds\":45,\"completed_at\":\"$COMPLETED2\"}"

echo ""
echo "=== 9. GET /api/v1/test/history?deckId=<id> ==="
HX=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/test/history?deckId=$DECK_ID" -H "$AUTH")
HX_BODY=$(echo "$HX" | head -n -1)
HX_CODE=$(echo "$HX" | tail -n1)
echo "$HX_BODY" | python -m json.tool 2>/dev/null
check "history status" "200" "$HX_CODE"
check "history count" "2" "$(echo "$HX_BODY" | jget "len(d['data'])")"
check "history newest first" "$RID2" "$(echo "$HX_BODY" | jget "d['data'][0]['id']")"
check "history item has deck_title" "QA4 Test Deck" "$(echo "$HX_BODY" | jget "d['data'][0]['deck_title']")"
check "history item shape (DTO field set)" "True" "$(echo "$HX_BODY" | jget "set(['id','deck_id','deck_title','total_questions','correct_count','duration_seconds','completed_at']) <= set(d['data'][0].keys())")"

echo ""
echo "=== 10. GET /api/v1/test/history — missing deckId -> 400 ==="
BD=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/test/history" -H "$AUTH")
check "missing deckId -> 400" "400" "$BD"

echo ""
echo "=== 11. Auth required on all new endpoints (401) ==="
for path in "/api/v1/decks/$DECK_ID/test-questions" "/api/v1/test/history?deckId=$DECK_ID"; do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$path")
  check "no-token 401: $path" "401" "$CODE"
done
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/test/results" -H 'Content-Type: application/json' -d '{}')
check "no-token 401: POST /api/v1/test/results" "401" "$CODE"

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
