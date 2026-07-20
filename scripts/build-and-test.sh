#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Builds one prebuilt-image variant and runs the smoke test inside it.
# Usage: build-and-test.sh <plcc-ng|plcc-ng-full> [image-tag]
set -euo pipefail

VARIANT="${1:?usage: build-and-test.sh <plcc-ng|plcc-ng-full> [image-tag]}"
TAG="${2:-ghcr.io/ourplcc/devcontainers/${VARIANT}:dev}"

cd "$(dirname "$0")/.."

bash scripts/sync-features.sh

devcontainer build \
    --workspace-folder "images/${VARIANT}" \
    --image-name "$TAG"

# Run the smoke test through the devcontainer CLI so feature-provided
# environment (containerEnv/remoteEnv, e.g. Java's PATH) is applied.
cp test/smoke-test.sh "images/${VARIANT}/smoke-test.sh"
devcontainer up --workspace-folder "images/${VARIANT}" --remove-existing-container
devcontainer exec --workspace-folder "images/${VARIANT}" bash smoke-test.sh "$VARIANT"
