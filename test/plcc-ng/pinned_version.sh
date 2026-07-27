#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Scenario: the version option pins the exact PyPI release.
set -e

source dev-container-features-test-lib

# Must match the version pinned in scenarios.json. Both are updated together
# by .github/workflows/check-plcc-ng-release.yml — keep this line's shape
# (EXPECTED_VERSION="<version>") intact so that update keeps working.
EXPECTED_VERSION="1.0.0"

check "plcc-version runs" plcc-version
check "exact version installed" bash -c \
    "/usr/local/pipx/venvs/plcc-ng/bin/python -m pip show plcc-ng | grep -q '^Version: ${EXPECTED_VERSION}\$'"

reportResults
