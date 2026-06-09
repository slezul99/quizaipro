#!/usr/bin/env bash
# Verification smoke test for Phase 5: AI Tutor conversations / messages / streaming
# Usage: bash api_v1/test_phase5_tutor.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5000}"
EMAIL="qa5_$(date +%s)@example.com"
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

echo "=== 0. Register fresh QA user, get bearer token ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qa5tester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
check "setup: register status" "201" "$REG_CODE"
ACCESS=$(echo "$REG_BODY" | jget "d['data']['access_token']")
AUTH="Authorization: Bearer $ACCESS"
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS})" || echo "  [FAIL] no access_token"

echo ""
echo "=== 0b. Create a deck (to test deck-linked conversations) ==="
SETUP=$(python - "$EMAIL" <<'PYEOF'
import sys, sqlite3
conn = sqlite3.connect("quizpro.db")
conn.row_factory = sqlite3.Row
email = sys.argv[1]
user = conn.execute("SELECT id FROM users WHERE username=?", (email,)).fetchone()
uid = user["id"]
cur = conn.execute("INSERT INTO decks (owner_id, name, description, is_public) VALUES (?, 'QA5 Tutor Deck', 'qa5', 0)", (uid,))
deck_id = cur.lastrowid
conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, 'Hello', 'Привет', '')", (deck_id,))
conn.commit()
print(f"DECK_ID={deck_id}")
PYEOF
)
DECK_ID=$(echo "$SETUP" | grep DECK_ID | cut -d= -f2)
echo "  -> deck_id=$DECK_ID"

echo ""
echo "=== 1. POST /api/v1/tutor/conversations (create, with deck link) ==="
CID="qa5conv-$(python -c "import uuid;print(uuid.uuid4().hex)")"
C1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/tutor/conversations" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$CID\",\"title\":\"My QA chat\",\"deck_id\":\"$DECK_ID\",\"deck_title\":\"QA5 Tutor Deck\"}")
C1_BODY=$(echo "$C1" | head -n -1)
C1_CODE=$(echo "$C1" | tail -n1)
echo "$C1_BODY" | python -m json.tool 2>/dev/null
check "create conversation status" "201" "$C1_CODE"
check "conversation id echoed" "$CID" "$(echo "$C1_BODY" | jget "d['data']['id']")"
check "conversation title" "My QA chat" "$(echo "$C1_BODY" | jget "d['data']['title']")"
check "conversation deck_id" "$DECK_ID" "$(echo "$C1_BODY" | jget "d['data']['deck_id']")"
check "conversation deck_title" "QA5 Tutor Deck" "$(echo "$C1_BODY" | jget "d['data']['deck_title']")"
check "conversation is_pinned default false" "False" "$(echo "$C1_BODY" | jget "d['data']['is_pinned']")"
check "conversation message_count starts at 0" "0" "$(echo "$C1_BODY" | jget "d['data']['message_count']")"
check "conversation has DTO field set" "True" "$(echo "$C1_BODY" | jget "set(['id','title','deck_id','deck_title','is_pinned','message_count','last_message_preview','created_at','updated_at']) <= set(d['data'].keys())")"

echo ""
echo "=== 2. POST /api/v1/tutor/conversations — retry same id (idempotency) ==="
C2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/tutor/conversations" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"id\":\"$CID\",\"title\":\"DIFFERENT TITLE\",\"deck_id\":\"$DECK_ID\",\"deck_title\":\"QA5 Tutor Deck\"}")
C2_BODY=$(echo "$C2" | head -n -1)
check "retry create keeps original title (idempotent)" "My QA chat" "$(echo "$C2_BODY" | jget "d['data']['title']")"

echo ""
echo "=== 3. GET /api/v1/tutor/conversations (list) ==="
L1=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/tutor/conversations" -H "$AUTH")
L1_BODY=$(echo "$L1" | head -n -1)
L1_CODE=$(echo "$L1" | tail -n1)
check "list status" "200" "$L1_CODE"
check "list contains our conversation" "True" "$(echo "$L1_BODY" | jget "any(c['id']=='$CID' for c in d['data'])")"

echo ""
echo "=== 4. PATCH /api/v1/tutor/conversations/<id> (rename) ==="
R1=$(curl -s -w '\n%{http_code}' -X PATCH "$BASE/api/v1/tutor/conversations/$CID" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"title":"Renamed chat"}')
R1_BODY=$(echo "$R1" | head -n -1)
R1_CODE=$(echo "$R1" | tail -n1)
check "rename status" "200" "$R1_CODE"
check "rename echoes new title" "Renamed chat" "$(echo "$R1_BODY" | jget "d['data']['title']")"
RCHK=$(curl -s "$BASE/api/v1/tutor/conversations" -H "$AUTH" | jget "[c['title'] for c in d['data'] if c['id']=='$CID'][0]")
check "rename persisted" "Renamed chat" "$RCHK"

echo ""
echo "=== 5. PATCH /api/v1/tutor/conversations/<id>/pin ==="
P1=$(curl -s -w '\n%{http_code}' -X PATCH "$BASE/api/v1/tutor/conversations/$CID/pin" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"is_pinned":true}')
P1_CODE=$(echo "$P1" | tail -n1)
check "pin status" "200" "$P1_CODE"
PCHK=$(curl -s "$BASE/api/v1/tutor/conversations" -H "$AUTH" | jget "[c['is_pinned'] for c in d['data'] if c['id']=='$CID'][0]")
check "pin persisted" "True" "$PCHK"

echo ""
echo "=== 6. POST /api/v1/tutor/stream (send message + SSE streaming reply) ==="
STREAM_OUT=$(curl -s -N -X POST "$BASE/api/v1/tutor/stream" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"conversation_id\":\"$CID\",\"content\":\"Skazhi privet odnim slovom\",\"deck_id\":\"$DECK_ID\"}")
echo "$STREAM_OUT" | head -c 600
echo ""
echo "  --- end of raw stream sample ---"
DELTA_COUNT=$(echo "$STREAM_OUT" | grep -c '^data: {"delta"')
DONE_COUNT=$(echo "$STREAM_OUT" | grep -c '^data: \[DONE\]')
check "stream emitted at least one delta chunk" "True" "$([ "$DELTA_COUNT" -ge 1 ] && echo True || echo False)"
check "stream terminated with [DONE]" "True" "$([ "$DONE_COUNT" -ge 1 ] && echo True || echo False)"

echo ""
echo "=== 7. GET /api/v1/tutor/conversations/<id>/messages (reflects persisted turn) ==="
M1=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/tutor/conversations/$CID/messages" -H "$AUTH")
M1_BODY=$(echo "$M1" | head -n -1)
M1_CODE=$(echo "$M1" | tail -n1)
echo "$M1_BODY" | python -m json.tool 2>/dev/null | head -40
check "messages status" "200" "$M1_CODE"
check "messages count == 2 (user + assistant)" "2" "$(echo "$M1_BODY" | jget "len(d['data'])")"
check "first message role=user" "user" "$(echo "$M1_BODY" | jget "d['data'][0]['role']")"
check "first message content echoed" "Skazhi privet odnim slovom" "$(echo "$M1_BODY" | jget "d['data'][0]['content']")"
check "second message role=assistant" "assistant" "$(echo "$M1_BODY" | jget "d['data'][1]['role']")"
check "second message has non-empty content" "True" "$(echo "$M1_BODY" | jget "len(d['data'][1]['content'].strip()) > 0")"
check "messages reference correct conversation_id" "True" "$(echo "$M1_BODY" | jget "all(m['conversation_id']=='$CID' for m in d['data'])")"
check "message has DTO field set" "True" "$(echo "$M1_BODY" | jget "set(['id','conversation_id','role','content','created_at']) <= set(d['data'][0].keys())")"

echo ""
echo "=== 8. List shows updated message_count + preview after the turn ==="
LCHK=$(curl -s "$BASE/api/v1/tutor/conversations" -H "$AUTH")
check "list message_count reflects 2 messages" "2" "$(echo "$LCHK" | jget "[c['message_count'] for c in d['data'] if c['id']=='$CID'][0]")"
check "list last_message_preview is non-null" "True" "$(echo "$LCHK" | jget "[c['last_message_preview'] for c in d['data'] if c['id']=='$CID'][0] is not None")"

echo ""
echo "=== 9. GET /api/v1/tutor/conversations?q=Renamed (search) ==="
S1=$(curl -s "$BASE/api/v1/tutor/conversations?q=Renamed" -H "$AUTH")
check "search finds renamed conversation" "True" "$(echo "$S1" | jget "any(c['id']=='$CID' for c in d['data'])")"
S2=$(curl -s "$BASE/api/v1/tutor/conversations?q=zzz_no_such_chat_zzz" -H "$AUTH")
check "search with no matches returns empty list" "0" "$(echo "$S2" | jget "len(d['data'])")"

echo ""
echo "=== 10. Validation & not-found cases ==="
BV=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/tutor/conversations" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"title":""}')
check "create with missing id -> 400" "400" "$BV"

BV2=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/tutor/conversations" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"id":"srv_123","title":"x"}')
check "create with reserved srv_ id -> 400" "400" "$BV2"

NF1=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/tutor/conversations/does-not-exist/messages" -H "$AUTH")
check "messages for missing conversation -> 404" "404" "$NF1"

NF2=$(curl -s -o /dev/null -w '%{http_code}' -X PATCH "$BASE/api/v1/tutor/conversations/does-not-exist" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"title":"x"}')
check "rename missing conversation -> 404" "404" "$NF2"

NF3=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/tutor/stream" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"conversation_id":"does-not-exist","content":"hi"}')
check "stream to missing conversation -> 404" "404" "$NF3"

echo ""
echo "=== 11. DELETE /api/v1/tutor/conversations/<id> ==="
D1=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE/api/v1/tutor/conversations/$CID" -H "$AUTH")
check "delete status" "204" "$D1"
DCHK=$(curl -s "$BASE/api/v1/tutor/conversations" -H "$AUTH" | jget "any(c['id']=='$CID' for c in d['data'])")
check "deleted conversation no longer listed" "False" "$DCHK"
NF4=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/tutor/conversations/$CID/messages" -H "$AUTH")
check "messages for deleted conversation -> 404" "404" "$NF4"

echo ""
echo "=== 12. Auth required on all new endpoints (401) ==="
for spec in "GET /api/v1/tutor/conversations" "GET /api/v1/tutor/conversations/x/messages"; do
  method=$(echo "$spec" | awk '{print $1}'); path=$(echo "$spec" | awk '{print $2}')
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -X "$method" "$BASE$path")
  check "no-token 401: $method $path" "401" "$CODE"
done
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/tutor/conversations" -H 'Content-Type: application/json' -d '{}')
check "no-token 401: POST /api/v1/tutor/conversations" "401" "$CODE"
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/tutor/stream" -H 'Content-Type: application/json' -d '{}')
check "no-token 401: POST /api/v1/tutor/stream" "401" "$CODE"
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE/api/v1/tutor/conversations/x")
check "no-token 401: DELETE /api/v1/tutor/conversations/x" "401" "$CODE"

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
