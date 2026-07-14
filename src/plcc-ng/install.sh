#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Installs plcc-ng from PyPI. Runs as root during devcontainer image build.
set -euo pipefail

VERSION="${VERSION:-latest}"

SPEC="plcc-ng"
if [ "$VERSION" != "latest" ]; then
    SPEC="plcc-ng==${VERSION}"
fi

# Install globally: apps in /usr/local/bin (default PATH), venvs under /usr/local/pipx.
export PIPX_HOME=/usr/local/pipx
export PIPX_BIN_DIR=/usr/local/bin

# The python feature (declared in dependsOn) installs pipx at
# /usr/local/py-utils/bin, which is not on PATH during image build.
PIPX="$(command -v pipx || true)"
if [ -z "$PIPX" ] && [ -x /usr/local/py-utils/bin/pipx ]; then
    PIPX=/usr/local/py-utils/bin/pipx
fi

if [ -n "$PIPX" ]; then
    "$PIPX" install "$SPEC"
else
    # Fallback when a base image provides python but no pipx.
    python3 -m pip install "$SPEC" \
        || python3 -m pip install --break-system-packages "$SPEC"
fi
