#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Feature test run by `devcontainer features test` against the default options.
set -e

source dev-container-features-test-lib

check "plcc-version on PATH" command -v plcc-version
check "plcc-version runs" plcc-version
check "plcc-make on PATH" command -v plcc-make
check "Python 3.12+ present (via dependsOn)" bash -c "python3 --version | grep -E '3\.(1[2-9]|[2-9][0-9])'"

reportResults
