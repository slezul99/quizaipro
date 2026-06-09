#!/usr/bin/env bash
# Curl-based lifecycle smoke test for /api/v1/auth/*
# Usage: bash api_v1/test_auth_lifecycle.sh [base_url]
set -uo pipefail

BASE="${1:-http://127.0.0.1:5055}"
EMAIL="qa_$(date +%s)@example.com"
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

echo "=== 1. POST /api/v1/auth/register ==="
REG=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qatester\"}")
REG_BODY=$(echo "$REG" | head -n -1)
REG_CODE=$(echo "$REG" | tail -n1)
echo "$REG_BODY" | python -m json.tool 2>/dev/null | head -30
check "register status" "201" "$REG_CODE"

ACCESS=$(echo "$REG_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
REFRESH=$(echo "$REG_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['refresh_token'])" 2>/dev/null)
USER_ID=$(echo "$REG_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['user']['id'])" 2>/dev/null)
[ -n "$ACCESS" ] && echo "  -> got access_token (len ${#ACCESS}), user id=$USER_ID" || echo "  [FAIL] no access_token in response"

echo ""
echo "=== 2. POST /api/v1/auth/register (duplicate email -> 409) ==="
DUP=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"username\":\"qatester2\"}")
check "duplicate register status" "409" "$DUP"

echo ""
echo "=== 3. POST /api/v1/auth/login ==="
LOGIN=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
LOGIN_BODY=$(echo "$LOGIN" | head -n -1)
LOGIN_CODE=$(echo "$LOGIN" | tail -n1)
check "login status" "200" "$LOGIN_CODE"
ACCESS=$(echo "$LOGIN_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
REFRESH=$(echo "$LOGIN_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['refresh_token'])" 2>/dev/null)
echo "  -> fresh access_token (len ${#ACCESS}), refresh_token (len ${#REFRESH})"

echo ""
echo "=== 4. POST /api/v1/auth/login (wrong password -> 401) ==="
BADLOGIN=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"wrongpass\"}")
check "wrong-password login status" "401" "$BADLOGIN"

echo ""
echo "=== 5. GET /api/v1/auth/me (with bearer token) ==="
ME=$(curl -s -w '\n%{http_code}' "$BASE/api/v1/auth/me" -H "Authorization: Bearer $ACCESS")
ME_BODY=$(echo "$ME" | head -n -1)
ME_CODE=$(echo "$ME" | tail -n1)
echo "$ME_BODY" | python -m json.tool 2>/dev/null
check "me status" "200" "$ME_CODE"
ME_EMAIL=$(echo "$ME_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['email'])" 2>/dev/null)
check "me returns correct email" "$EMAIL" "$ME_EMAIL"

echo ""
echo "=== 6. GET /api/v1/auth/me (no token -> 401) ==="
ME_NOAUTH=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/v1/auth/me")
check "me without token status" "401" "$ME_NOAUTH"

echo ""
echo "=== 7. POST /api/v1/auth/refresh (rotation) ==="
REF=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/refresh" \
  -H 'Content-Type: application/json' \
  -d "{\"refresh_token\":\"$REFRESH\"}")
REF_BODY=$(echo "$REF" | head -n -1)
REF_CODE=$(echo "$REF" | tail -n1)
check "refresh status" "200" "$REF_CODE"
NEW_ACCESS=$(echo "$REF_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
NEW_REFRESH=$(echo "$REF_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['refresh_token'])" 2>/dev/null)
echo "  -> rotated access_token (len ${#NEW_ACCESS}), refresh_token (len ${#NEW_REFRESH})"

echo ""
echo "=== 8. POST /api/v1/auth/refresh with OLD (now-revoked) token -> 401 + chain revoked ==="
OLD_REF=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/refresh" \
  -H 'Content-Type: application/json' \
  -d "{\"refresh_token\":\"$REFRESH\"}")
check "reuse of rotated-out refresh token status" "401" "$OLD_REF"

echo "  -> verifying theft-detection revoked the NEW token too (chain invalidation)"
CHAIN_CHECK=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/refresh" \
  -H 'Content-Type: application/json' \
  -d "{\"refresh_token\":\"$NEW_REFRESH\"}")
check "new token also revoked after reuse-of-old detected" "401" "$CHAIN_CHECK"

echo ""
echo "=== 9. Re-login to get a clean token pair for logout test ==="
LOGIN2=$(curl -s -w '\n%{http_code}' -X POST "$BASE/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
LOGIN2_BODY=$(echo "$LOGIN2" | head -n -1)
ACCESS2=$(echo "$LOGIN2_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null)
REFRESH2=$(echo "$LOGIN2_BODY" | python -c "import sys,json; print(json.load(sys.stdin)['data']['refresh_token'])" 2>/dev/null)
echo "  -> got fresh pair for logout test"

echo ""
echo "=== 10. POST /api/v1/auth/logout ==="
LOGOUT=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/logout" \
  -H "Authorization: Bearer $ACCESS2" \
  -H 'Content-Type: application/json' \
  -d "{\"refresh_token\":\"$REFRESH2\"}")
check "logout status" "204" "$LOGOUT"

echo ""
echo "=== 11. POST /api/v1/auth/refresh with logged-out token -> 401 ==="
POST_LOGOUT_REF=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/v1/auth/refresh" \
  -H 'Content-Type: application/json' \
  -d "{\"refresh_token\":\"$REFRESH2\"}")
check "refresh after logout status" "401" "$POST_LOGOUT_REF"

echo ""
echo "============================================="
echo "RESULT: $pass passed, $fail failed"
echo "============================================="
[ "$fail" -eq 0 ]
