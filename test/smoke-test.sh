#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Smoke test: verifies a prebuilt image has all required tools.
# Run inside the container: smoke-test.sh <plcc-ng|plcc-ng-full>
set -euo pipefail

VARIANT="${1:?usage: smoke-test.sh <plcc-ng|plcc-ng-full>}"
case "$VARIANT" in
    plcc-ng|plcc-ng-full) ;;
    *) echo "usage: smoke-test.sh <plcc-ng|plcc-ng-full>" >&2; exit 2 ;;
esac

PASS=0
FAIL=0

check() {
    local label="$1"
    local cmd="$2"
    if bash -c "$cmd" > /dev/null 2>&1; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== plcc-ng environment smoke test ($VARIANT) ==="

check "plcc-version runs"     "plcc-version"
check "plcc-make on PATH"     "command -v plcc-make"
check "plcc-scan on PATH"     "command -v plcc-scan"
check "plcc-parse on PATH"    "command -v plcc-parse"
check "plcc-rep on PATH"      "command -v plcc-rep"
check "Python 3.12+ present"  "python3 --version 2>&1 | grep -qE '3\.(1[2-9]|[2-9][0-9])'"
check "Java 21+ present"      "java --version 2>&1 | grep -qE '(openjdk|java) (2[1-9]|[3-9][0-9])'"
check "Node present"          "command -v node"
check "npm present"           "command -v npm"
check "git present"           "command -v git"

if [ "$VARIANT" = "plcc-ng-full" ]; then
    check "GHC present"   "command -v ghc || [ -e /usr/local/.ghcup/bin/ghc ] || [ -e \$HOME/.ghcup/bin/ghc ]"
    check "cabal present" "command -v cabal || [ -e /usr/local/.ghcup/bin/cabal ] || [ -e \$HOME/.ghcup/bin/cabal ]"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
