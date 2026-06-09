#!/usr/bin/env bash
# Read-only API smoke test for Phase 2: dashboard / library / marketplace
# Usage: bash api_v1/test_phase2_readonly.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5055}"
EMAIL="qa2_$(date +%s)@example.com"
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

echo "=== 0. Register + login a fresh QA user, get bearer token ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qa2tester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
check "setup: register status" "201" "$REG_CODE"
ACCESS=$(echo "$REG_BODY" | jget "d['data']['access_token']")
AUTH="Authorization: Bearer $ACCESS"
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS})" || echo "  [FAIL] no access_token"

echo ""
echo "=== 1. GET /api/v1/dashboard ==="
DASH=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/dashboard" -H "$AUTH")
DASH_BODY=$(echo "$DASH" | head -n -1)
DASH_CODE=$(echo "$DASH" | tail -n1)
echo "$DASH_BODY" | python -m json.tool 2>/dev/null | head -40
check "dashboard status" "200" "$DASH_CODE"
check "dashboard has xp.level" "1" "$(echo "$DASH_BODY" | jget "d['data']['xp']['level']")"
check "dashboard has streak.current_streak key" "0" "$(echo "$DASH_BODY" | jget "d['data']['streak']['current_streak']")"
check "dashboard has due_reviews.total_due key" "0" "$(echo "$DASH_BODY" | jget "d['data']['due_reviews']['total_due']")"
check "dashboard user_display_name" "qa2tester" "$(echo "$DASH_BODY" | jget "d['data']['user_display_name']")"

echo ""
echo "=== 2. GET /api/v1/dashboard (no token -> 401) ==="
NOAUTH=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/dashboard")
check "dashboard without token status" "401" "$NOAUTH"

echo ""
echo "=== 3. GET /api/v1/dashboard/activity ==="
ACT=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/dashboard/activity?limit=5" -H "$AUTH")
ACT_BODY=$(echo "$ACT" | head -n -1)
ACT_CODE=$(echo "$ACT" | tail -n1)
check "activity status" "200" "$ACT_CODE"
check "activity data is a list" "list" "$(echo "$ACT_BODY" | jget "type(d['data']).__name__")"
echo "  -> activity items: $(echo "$ACT_BODY" | jget "len(d['data'])")"

echo ""
echo "=== 4. GET /api/v1/library/decks ==="
LD=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/library/decks?page=1&page_size=10" -H "$AUTH")
LD_BODY=$(echo "$LD" | head -n -1)
LD_CODE=$(echo "$LD" | tail -n1)
check "library decks status" "200" "$LD_CODE"
check "library decks has items/page/total_pages/total_count" "True" "$(echo "$LD_BODY" | jget "set(['items','page','total_pages','total_count']) <= set(d['data'].keys())")"

echo ""
echo "=== 5. GET /api/v1/library/collections ==="
LC=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/library/collections" -H "$AUTH")
LC_CODE=$(echo "$LC" | tail -n1)
LC_BODY=$(echo "$LC" | head -n -1)
check "library collections status" "200" "$LC_CODE"
check "library collections paginated shape" "True" "$(echo "$LC_BODY" | jget "set(['items','page','total_pages','total_count']) <= set(d['data'].keys())")"

echo ""
echo "=== 6. GET /api/v1/library/search?q=test ==="
LS=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/library/search?q=test" -H "$AUTH")
LS_CODE=$(echo "$LS" | tail -n1)
check "library search status" "200" "$LS_CODE"

echo ""
echo "=== 7. GET /api/v1/marketplace/subjects ==="
MS=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/marketplace/subjects" -H "$AUTH")
MS_BODY=$(echo "$MS" | head -n -1)
MS_CODE=$(echo "$MS" | tail -n1)
check "marketplace subjects status" "200" "$MS_CODE"
check "marketplace subjects data is a list" "list" "$(echo "$MS_BODY" | jget "type(d['data']).__name__")"
SUBJ_COUNT=$(echo "$MS_BODY" | jget "len(d['data'])")
echo "  -> subjects returned: $SUBJ_COUNT"

echo ""
echo "=== 8. GET /api/v1/marketplace/decks ==="
MD=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/marketplace/decks?page=1&limit=10" -H "$AUTH")
MD_BODY=$(echo "$MD" | head -n -1)
MD_CODE=$(echo "$MD" | tail -n1)
check "marketplace decks status" "200" "$MD_CODE"
check "marketplace decks paginated shape" "True" "$(echo "$MD_BODY" | jget "set(['items','page','total_pages','total_count']) <= set(d['data'].keys())")"
DECK_ID=$(echo "$MD_BODY" | jget "d['data']['items'][0]['id'] if d['data']['items'] else ''")
echo "  -> first public marketplace deck id: ${DECK_ID:-<none>}"

echo ""
echo "=== 9. GET /api/v1/marketplace/decks/<id> ==="
if [ -n "$DECK_ID" ]; then
  MDD=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/marketplace/decks/$DECK_ID" -H "$AUTH")
  MDD_BODY=$(echo "$MDD" | head -n -1)
  MDD_CODE=$(echo "$MDD" | tail -n1)
  check "marketplace deck detail status" "200" "$MDD_CODE"
  check "marketplace deck detail id matches" "$DECK_ID" "$(echo "$MDD_BODY" | jget "d['data']['id']")"
else
  echo "  [SKIP] no public decks exist in this DB to fetch detail for"
fi

echo ""
echo "=== 10. GET /api/v1/marketplace/decks/<id> (non-existent -> 404) ==="
NF=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/marketplace/decks/99999999" -H "$AUTH")
check "marketplace deck detail 404 for missing id" "404" "$NF"

echo ""
echo "=== 11. GET /api/v1/marketplace/search?q=a ==="
SR=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/marketplace/search?q=a&page=1&limit=5" -H "$AUTH")
SR_CODE=$(echo "$SR" | tail -n1)
SR_BODY=$(echo "$SR" | head -n -1)
check "marketplace search status" "200" "$SR_CODE"
check "marketplace search paginated shape" "True" "$(echo "$SR_BODY" | jget "set(['items','page','total_pages','total_count']) <= set(d['data'].keys())")"

echo ""
echo "=== 12. Read-only endpoints reject unauthenticated requests (401) ==="
for path in "/api/v1/dashboard/activity" "/api/v1/library/decks" "/api/v1/library/collections" \
            "/api/v1/library/search" "/api/v1/marketplace/subjects" "/api/v1/marketplace/decks" \
            "/api/v1/marketplace/search"; do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$path")
  check "no-token 401: $path" "401" "$CODE"
done

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
