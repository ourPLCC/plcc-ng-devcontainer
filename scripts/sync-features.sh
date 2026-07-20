#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Copies the canonical feature source (src/plcc-ng) into each image
# workspace. The copies are gitignored; run this before any image build.
set -euo pipefail

cd "$(dirname "$0")/.."

for image in images/*/; do
    dest="${image}.devcontainer/features/plcc-ng"
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -R src/plcc-ng "$dest"
    echo "synced src/plcc-ng -> $dest"
done
