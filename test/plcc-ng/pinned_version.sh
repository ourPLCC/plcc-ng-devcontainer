#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Scenario: the version option pins the exact PyPI release.
set -e

source dev-container-features-test-lib

check "plcc-version runs" plcc-version
check "exact version installed" bash -c \
    "/usr/local/pipx/venvs/plcc-ng/bin/python -m pip show plcc-ng | grep -q '^Version: 1.0.0$'"

reportResults
