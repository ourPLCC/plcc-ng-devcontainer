#!/bin/bash
# SPDX-FileCopyrightText: 2026 ourPLCC contributors
# SPDX-License-Identifier: GPL-3.0-or-later

# REUSE wrapper script
# Runs REUSE tool from Docker container with current directory mounted as /data

docker run --rm --volume "$(pwd):/data" fsfe/reuse "$@"
