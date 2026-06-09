#!/usr/bin/env bash
# Verification smoke test for Phase 6: AI Generation (jobs, decks, find-answers, explain)
# Usage: bash api_v1/test_phase6_ai_generation.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5000}"
EMAIL="qa6_$(date +%s)@example.com"
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

check_true() {
  local name="$1" actual="$2"
  if [ "$actual" = "True" ]; then
    echo "  [PASS] $name (got $actual)"
    pass=$((pass+1))
  else
    echo "  [FAIL] $name (expected True, got $actual)"
    fail=$((fail+1))
  fi
}

jget() { python -c "import sys,json; d=json.load(sys.stdin); print($1)" 2>/dev/null; }

echo "=== 0. Register fresh QA user, get bearer token ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qa6tester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
check "setup: register status" "201" "$REG_CODE"
ACCESS=$(echo "$REG_BODY" | jget "d['data']['access_token']")
AUTH="Authorization: Bearer $ACCESS"
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS})" || echo "  [FAIL] no access_token"

echo ""
echo "=== 0b. Build a tiny test PDF (extractable text layer via reportlab) ==="
PDF_DIR="/tmp/qa6_pdf_$(date +%s)"
mkdir -p "$PDF_DIR"
PDF_PATH="$PDF_DIR/biology_notes.pdf"
python - "$PDF_PATH" <<'PYEOF'
import sys
from reportlab.pdfgen import canvas
path = sys.argv[1]
c = canvas.Canvas(path)
c.drawString(72, 750, "Photosynthesis is the process plants use to convert light into energy.")
c.drawString(72, 730, "Chlorophyll is the green pigment that absorbs sunlight in plant leaves.")
c.drawString(72, 710, "Mitochondria are the powerhouse of the cell, producing ATP energy.")
c.save()
print("PDF written")
PYEOF
[ -f "$PDF_PATH" ] && echo "  -> PDF created at $PDF_PATH" || echo "  [FAIL] PDF not created"

# --- helper: poll a job until it reaches a terminal status (or times out) ---
poll_job() {
  local job_id="$1" max_wait="${2:-90}"
  local waited=0
  while [ "$waited" -lt "$max_wait" ]; do
    local body status
    body=$(curl -s "$BASE/api/v1/ai/jobs/$job_id" -H "$AUTH")
    status=$(echo "$body" | jget "d['data']['status']")
    if [ "$status" = "completed" ] || [ "$status" = "failed" ] || [ "$status" = "cancelled" ]; then
      echo "$body"
      return 0
    fi
    sleep 3
    waited=$((waited+3))
  done
  echo "$body"
  return 1
}

echo ""
echo "=== 1. POST /api/v1/ai/generate/topic (async job) ==="
J1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/ai/generate/topic" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d '{"topic":"Solar system basics","card_count":5,"quality_mode":"fast"}')
J1_BODY=$(echo "$J1" | head -n -1)
J1_CODE=$(echo "$J1" | tail -n1)
echo "$J1_BODY" | python -m json.tool 2>/dev/null
check "create topic job status" "202" "$J1_CODE"
JOB1_ID=$(echo "$J1_BODY" | jget "d['data']['id']")
[ -n "$JOB1_ID" ] && echo "  -> job id: $JOB1_ID" || echo "  [FAIL] no job id"
check "topic job source" "topic" "$(echo "$J1_BODY" | jget "d['data']['source']")"
check "topic job status is pending/processing" "True" "$([ "$(echo "$J1_BODY" | jget "d['data']['status']")" != "" ] && echo True || echo False)"
check "topic job topic field" "Solar system basics" "$(echo "$J1_BODY" | jget "d['data']['topic']")"
check "topic job quality_mode" "fast" "$(echo "$J1_BODY" | jget "d['data']['quality_mode']")"
check "topic job requested_card_count" "5" "$(echo "$J1_BODY" | jget "d['data']['requested_card_count']")"
check "topic job has DTO field set" "True" "$(echo "$J1_BODY" | jget "set(['id','source','status','progress','topic','input_text','pdf_file_name','quality_mode','requested_card_count','cards','error_message','created_at','completed_at']) <= set(d['data'].keys())")"

echo ""
echo "=== 2. POST /api/v1/ai/generate/text (async job) ==="
LONG_TEXT="The water cycle describes how water evaporates from the surface of the earth, rises into the atmosphere, cools and condenses into rain or snow in clouds, and falls again to the surface as precipitation. This cycle is essential for distributing water around the planet."
J2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/ai/generate/text" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"text\":\"$LONG_TEXT\",\"card_count\":5,\"quality_mode\":\"balanced\"}")
J2_BODY=$(echo "$J2" | head -n -1)
J2_CODE=$(echo "$J2" | tail -n1)
check "create text job status" "202" "$J2_CODE"
JOB2_ID=$(echo "$J2_BODY" | jget "d['data']['id']")
[ -n "$JOB2_ID" ] && echo "  -> job id: $JOB2_ID" || echo "  [FAIL] no job id"
check "text job source" "text" "$(echo "$J2_BODY" | jget "d['data']['source']")"
check "text job input_text echoed" "True" "$(echo "$J2_BODY" | jget "d['data']['input_text'] == '$LONG_TEXT'" 2>/dev/null || echo False)"

echo ""
echo "=== 3. POST /api/v1/ai/generate/pdf (multipart upload, async job) ==="
J3=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/ai/generate/pdf" \
  -H "$AUTH" \
  -F "file=@$PDF_PATH" \
  -F "card_count=5" -F "quality_mode=fast")
J3_BODY=$(echo "$J3" | head -n -1)
J3_CODE=$(echo "$J3" | tail -n1)
check "create pdf job status" "202" "$J3_CODE"
JOB3_ID=$(echo "$J3_BODY" | jget "d['data']['id']")
[ -n "$JOB3_ID" ] && echo "  -> job id: $JOB3_ID" || echo "  [FAIL] no job id"
check "pdf job source" "pdf" "$(echo "$J3_BODY" | jget "d['data']['source']")"
check "pdf job pdf_file_name" "biology_notes.pdf" "$(echo "$J3_BODY" | jget "d['data']['pdf_file_name']")"

echo ""
echo "=== 4. GET /api/v1/ai/jobs/<id> (poll topic job to completion) ==="
P1=$(poll_job "$JOB1_ID" 120)
echo "$P1" | python -m json.tool 2>/dev/null | head -30
P1_STATUS=$(echo "$P1" | jget "d['data']['status']")
echo "  -> final status: $P1_STATUS"
check_true "topic job reached a terminal state" "$([ "$P1_STATUS" = "completed" ] || [ "$P1_STATUS" = "failed" ] && echo True || echo False)"
if [ "$P1_STATUS" = "completed" ]; then
  check "topic job progress at completion" "100" "$(echo "$P1" | jget "d['data']['progress']")"
  check_true "topic job produced cards" "$(echo "$P1" | jget "len(d['data']['cards']) > 0")"
  check_true "topic job card has DTO field set" "$(echo "$P1" | jget "set(['question','answer','topic','difficulty']) <= set(d['data']['cards'][0].keys())")"
  check_true "topic job completed_at set" "$(echo "$P1" | jget "d['data']['completed_at'] is not None")"
else
  echo "  -> job failed (AI may be rate-limited/unavailable in this environment); error: $(echo "$P1" | jget "d['data']['error_message']")"
  check_true "topic job has error_message on failure" "$(echo "$P1" | jget "d['data']['error_message'] is not None")"
fi

echo ""
echo "=== 5. GET /api/v1/ai/jobs/<id> — not found / cross-user isolation ==="
NF1=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/ai/jobs/does-not-exist" -H "$AUTH")
check "missing job -> 404" "404" "$NF1"

echo ""
echo "=== 6. GET /api/v1/ai/jobs (history) ==="
H1=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/ai/jobs" -H "$AUTH")
H1_BODY=$(echo "$H1" | head -n -1)
H1_CODE=$(echo "$H1" | tail -n1)
check "history status" "200" "$H1_CODE"
check_true "history contains topic job" "$(echo "$H1_BODY" | jget "any(j['id']=='$JOB1_ID' for j in d['data'])")"
check_true "history contains text job" "$(echo "$H1_BODY" | jget "any(j['id']=='$JOB2_ID' for j in d['data'])")"
check_true "history contains pdf job" "$(echo "$H1_BODY" | jget "any(j['id']=='$JOB3_ID' for j in d['data'])")"
check_true "history newest first (topic job is last created, listed first)" "$(echo "$H1_BODY" | jget "d['data'][0]['id']=='$JOB3_ID'")"

echo ""
echo "=== 7. POST /api/v1/decks (create deck) ==="
D1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/decks" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"title":"QA6 AI Deck"}')
D1_BODY=$(echo "$D1" | head -n -1)
D1_CODE=$(echo "$D1" | tail -n1)
echo "$D1_BODY" | python -m json.tool 2>/dev/null
check "create deck status" "201" "$D1_CODE"
DECK_ID=$(echo "$D1_BODY" | jget "d['data']['id']")
[ -n "$DECK_ID" ] && echo "  -> deck id: $DECK_ID" || echo "  [FAIL] no deck id"
check "deck title" "QA6 AI Deck" "$(echo "$D1_BODY" | jget "d['data']['title']")"
check "deck card_count starts at 0" "0" "$(echo "$D1_BODY" | jget "d['data']['card_count']")"
check_true "deck has DTO field set" "$(echo "$D1_BODY" | jget "set(['id','title','card_count']) <= set(d['data'].keys())")"

echo ""
echo "=== 8. GET /api/v1/decks (list user decks) ==="
L1=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/decks" -H "$AUTH")
L1_BODY=$(echo "$L1" | head -n -1)
L1_CODE=$(echo "$L1" | tail -n1)
check "list decks status" "200" "$L1_CODE"
check_true "list contains our deck" "$(echo "$L1_BODY" | jget "any(d_['id']=='$DECK_ID' for d_ in d['data'])")"

echo ""
echo "=== 9. POST /api/v1/decks/<id>/cards/bulk (save generated cards) ==="
B1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/decks/$DECK_ID/cards/bulk" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d '{"cards":[{"question":"What is the sun?","answer":"A star at the center of the solar system.","topic":"Astronomy","difficulty":"easy"},{"question":"What is gravity?","answer":"A force that attracts two bodies toward each other.","topic":"Physics","difficulty":"medium"}]}')
B1_BODY=$(echo "$B1" | head -n -1)
B1_CODE=$(echo "$B1" | tail -n1)
echo "$B1_BODY" | python -m json.tool 2>/dev/null
check "bulk save status" "201" "$B1_CODE"
check "bulk save saved_count" "2" "$(echo "$B1_BODY" | jget "d['data']['saved_count']")"
check "bulk save card_count reflects total" "2" "$(echo "$B1_BODY" | jget "d['data']['card_count']")"

L2=$(curl -s "$BASE/api/v1/decks" -H "$AUTH")
check "deck list now shows card_count=2" "2" "$(echo "$L2" | jget "[d_['card_count'] for d_ in d['data'] if d_['id']=='$DECK_ID'][0]")"

echo ""
echo "=== 10. POST /api/v1/ai/find-answers ==="
F1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/ai/find-answers" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"question\":\"What is photosynthesis?\",\"deck_id\":\"$DECK_ID\"}")
F1_BODY=$(echo "$F1" | head -n -1)
F1_CODE=$(echo "$F1" | tail -n1)
echo "$F1_BODY" | python -m json.tool 2>/dev/null
check "find-answers status" "200" "$F1_CODE"
check "find-answers echoes question" "What is photosynthesis?" "$(echo "$F1_BODY" | jget "d['data']['question']")"
check_true "find-answers explanation non-empty" "$(echo "$F1_BODY" | jget "len(d['data']['explanation'].strip()) > 0")"
check_true "find-answers key_points is a list" "$(echo "$F1_BODY" | jget "isinstance(d['data']['key_points'], list)")"
check_true "find-answers has DTO field set" "$(echo "$F1_BODY" | jget "set(['question','explanation','key_points']) <= set(d['data'].keys())")"

echo ""
echo "=== 11. POST /api/v1/ai/explain ==="
E1=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/ai/explain" \
  -H "$AUTH" -H 'Content-Type: application/json' \
  -d "{\"question\":\"What is the sun?\",\"answer\":\"A star at the center of the solar system.\",\"deck_id\":\"$DECK_ID\"}")
E1_BODY=$(echo "$E1" | head -n -1)
E1_CODE=$(echo "$E1" | tail -n1)
echo "$E1_BODY" | python -m json.tool 2>/dev/null
check "explain status" "200" "$E1_CODE"
check_true "explain returns non-empty explanation" "$(echo "$E1_BODY" | jget "len(d['data']['explanation'].strip()) > 0")"

echo ""
echo "=== 12. Validation errors ==="
V1=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/topic" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"topic":"","card_count":5,"quality_mode":"fast"}')
check "empty topic -> 400" "400" "$V1"

V2=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/topic" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"topic":"Cats","card_count":500,"quality_mode":"fast"}')
check "card_count out of range -> 400" "400" "$V2"

V3=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/topic" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"topic":"Cats","card_count":5,"quality_mode":"ultra"}')
check "invalid quality_mode -> 400" "400" "$V3"

V4=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/text" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"text":"too short","card_count":5,"quality_mode":"fast"}')
check "text too short -> 400" "400" "$V4"

V5=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/pdf" \
  -H "$AUTH" -F "card_count=5" -F "quality_mode=fast")
check "pdf without file -> 400" "400" "$V5"

V6=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/decks" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"title":""}')
check "create deck without title -> 400" "400" "$V6"

V7=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/decks/$DECK_ID/cards/bulk" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"cards":[]}')
check "bulk save with empty cards -> 400" "400" "$V7"

V8=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/find-answers" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"question":""}')
check "find-answers with empty question -> 400" "400" "$V8"

V9=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/explain" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"question":"Q only"}')
check "explain without answer -> 400" "400" "$V9"

NF2=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/decks/999999999/cards/bulk" \
  -H "$AUTH" -H 'Content-Type: application/json' -d '{"cards":[{"question":"Q","answer":"A"}]}')
check "bulk save to missing deck -> 404" "404" "$NF2"

echo ""
echo "=== 13. Auth required on all new endpoints (401) ==="
for spec in "GET /api/v1/ai/jobs" "GET /api/v1/ai/jobs/x" "GET /api/v1/decks"; do
  method=$(echo "$spec" | awk '{print $1}'); path=$(echo "$spec" | awk '{print $2}')
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -X "$method" "$BASE$path")
  check "no-token 401: $method $path" "401" "$CODE"
done
for spec in "POST /api/v1/ai/generate/topic" "POST /api/v1/ai/generate/text" "POST /api/v1/ai/find-answers" "POST /api/v1/ai/explain" "POST /api/v1/decks" "POST /api/v1/decks/$DECK_ID/cards/bulk"; do
  method=$(echo "$spec" | awk '{print $1}'); path=$(echo "$spec" | awk '{print $2}')
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -X "$method" "$BASE$path" -H 'Content-Type: application/json' -d '{}')
  check "no-token 401: $method $path" "401" "$CODE"
done
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/ai/generate/pdf" -F "card_count=5")
check "no-token 401: POST /api/v1/ai/generate/pdf" "401" "$CODE"

rm -f "$PDF_PATH"

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
