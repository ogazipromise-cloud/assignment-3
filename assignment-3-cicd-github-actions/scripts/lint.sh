#!/usr/bin/env bash

set -u

FAILED=0

REQUIRED_FILES=(
"app/app.sh"
"scripts/lint.sh"
"scripts/build.sh"
"tests/test.sh"
"Dockerfile"
"compose.yaml"
".dockerignore"
".github/workflows/ci.yml"
)

echo "===== Required Files Check ====="

for file in "${REQUIRED_FILES[@]}"; do
if [[ -f "$file" ]]; then
echo "[PASS] $file exists"
else
echo "[FAIL] $file is missing"
FAILED=1
fi
done

echo
echo "===== Bash Syntax Check ====="

SCRIPTS=(
"app/app.sh"
"scripts/lint.sh"
"scripts/build.sh"
"tests/test.sh"
)

for script in "${SCRIPTS[@]}"; do
if [[ -f "$script" ]]; then
if bash -n "$script"; then
echo "[PASS] Syntax valid: $script"
else
echo "[FAIL] Syntax error: $script"
FAILED=1
fi
fi
done

if command -v shellcheck >/dev/null 2>&1; then
echo
echo "===== ShellCheck ====="


for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if shellcheck "$script"; then
            echo "[PASS] ShellCheck: $script"
        else
            echo "[FAIL] ShellCheck: $script"
            FAILED=1
        fi
    fi
done


else
echo
echo "ShellCheck is not installed. Skipping ShellCheck."
fi

echo

if [[ "$FAILED" -eq 0 ]]; then
echo "Linting completed successfully."
exit 0
else
echo "Linting failed."
exit 1
fi
