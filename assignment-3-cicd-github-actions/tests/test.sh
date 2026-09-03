#!/usr/bin/env bash

set -u

APP="./app/app.sh"
FAILED=0

pass() {
echo "[PASS] $1"
}

fail() {
echo "[FAIL] $1"
FAILED=1
}

echo "===== Running Application Tests ====="

# Test 1: Help command

if "$APP" help | grep -q "Usage:"; then
pass "Help command"
else
fail "Help command"
fi

# Test 2: System information

if "$APP" system-info | grep -q "System Information"; then
pass "System information command"
else
fail "System information command"
fi

# Test 3: Invalid command

"$APP" invalid-command >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
pass "Invalid command"
else
fail "Invalid command (expected exit code 2, got $STATUS)"
fi

# Test 4: Missing host

"$APP" check-host >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
pass "Missing host"
else
fail "Missing host (expected exit code 2, got $STATUS)"
fi

# Test 5: Valid host

if "$APP" check-host localhost | grep -q "Resolved Address"; then
pass "Valid host"
else
fail "Valid host"
fi

# Test 6: Missing port

"$APP" check-port localhost >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
pass "Missing port"
else
fail "Missing port (expected exit code 2, got $STATUS)"
fi

# Test 7: Non-numeric port

"$APP" check-port localhost abc >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
pass "Non-numeric port"
else
fail "Non-numeric port (expected exit code 2, got $STATUS)"
fi

# Test 8: Out-of-range port

"$APP" check-port localhost 70000 >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
pass "Out-of-range port"
else
fail "Out-of-range port (expected exit code 2, got $STATUS)"
fi

if [[ "$FAILED" -eq 0 ]]; then
echo
echo "All tests passed."
exit 0
else
echo
echo "One or more tests failed."
exit 1
fi
