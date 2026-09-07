#!/usr/bin/env bash

set -u

IMAGE_NAME="devops-tool"
FAILED=0

echo "===== Building Docker Image ====="

if docker build -t "$IMAGE_NAME" .; then
    echo "[PASS] Docker image built successfully"
else
    echo "[FAIL] Docker image build failed"
    exit 1
fi

echo
echo "===== Docker Smoke Tests ====="

echo "Testing help command..."

if docker run --rm "$IMAGE_NAME" help >/dev/null 2>&1; then
    echo "[PASS] Help command"
else
    echo "[FAIL] Help command"
    FAILED=1
fi

echo "Testing system-info command..."

if docker run --rm "$IMAGE_NAME" system-info >/dev/null 2>&1; then
    echo "[PASS] System-info command"
else
    echo "[FAIL] System-info command"
    FAILED=1
fi

echo "Testing invalid command..."

docker run --rm "$IMAGE_NAME" invalid-command >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
    echo "[PASS] Invalid command returns exit code 2"
else
    echo "[FAIL] Invalid command returned exit code $STATUS"
    FAILED=1
fi

echo

if [[ "$FAILED" -eq 0 ]]; then
    echo "All Docker smoke tests passed."
    exit 0
else
    echo "One or more Docker smoke tests failed."
    exit 1
fi

