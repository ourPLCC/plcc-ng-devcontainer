# Contributing to plcc-ng-devcontainer

This builds on the [ourPLCC developer guide](https://github.com/ourPLCC/dev/blob/main/CONTRIBUTING.md); read that first. Below is what's specific to this repo, and where it differs.

For how the images and feature are built, versioned, and released, see the [maintainer guide](docs/maintainer-guide.md).

## Where this repo differs from the org guide

Nowhere at present. Two leftovers from before the org guide are history, not
deviations: [docs/superpowers/specs/](docs/superpowers/specs/) and
[docs/superpowers/plans/](docs/superpowers/plans/) hold kept specs and plans.
Merged specs and plans are frozen, so they stay. New specs go in
[dev-docs/specs/](dev-docs/specs/), and no new plans are kept.

## Development environment

Open the repo in its devcontainer, in VS Code on your own machine. Before the
container is created, it clones the [ourPLCC/dev](https://github.com/ourPLCC/dev)
repo beside this one, as `../dev`, unless that folder already exists. The
container mounts it at `/workspaces/dev`, points the `backlog` CLI at it
through `BACKLOG_CWD`, and installs the pinned `backlog` version. In the
tracker, this repo's `project` value is `plcc-ng-devcontainer`.

A Codespace cannot clone or mount `../dev`, so this repo is not developed in
Codespaces. That affects only work on this repo: the images and feature it
publishes work in Codespaces as before.

The devcontainer also includes Node, Docker-in-Docker, and the devcontainer
CLI, so the commands below run inside it.

[AGENTS.md](AGENTS.md) imports files from `../dev`. Claude Code loads imports
from outside the repo only once they are approved, and until then skips them
without an error, so agents never load the org guide. It does not reliably ask
for that approval, and the approval lives in `~/.claude.json`, which a rebuild
discards. So the container approves them when it is created, by running
[bin/install/claude-imports.bash](bin/install/claude-imports.bash). To check,
run `/memory` in a session and confirm it lists `ORG-AGENTS.md` and both
`CONTRIBUTING.md` files. If they are missing, quit every Claude Code session,
since a running one can overwrite `~/.claude.json`, then run the script and
start a new session.

Keep each import in `AGENTS.md` on its own line with nothing after the path:
Claude Code reads an import up to the next whitespace, so `@file.md,` looks
for a file named `file.md,` and silently skips it.

## Making a change

1. Fork and clone this repository, and open it in its devcontainer.
2. Make your changes, and test them with the commands below.
3. Open a PR. CI tests the feature and builds both images as `pr-{N}` tags.

Commit types decide releases: `fix:` → patch, `feat:` → minor, `feat:`
**with a `BREAKING CHANGE:` footer** → major, and `ci:`/`docs:`/`chore:`/`test:`
→ no release.

Write the footer, not `feat!:`. semantic-release's Angular preset does not parse
the `!` shorthand, so `feat!:` on its own matches nothing and produces **no
release at all** — easy to miss, because the pipeline still goes green.

## Common commands

| Command | What it does |
|---|---|
| `devcontainer features test --project-folder . --features plcc-ng --base-image mcr.microsoft.com/devcontainers/base:ubuntu` | Test the feature. |
| `bash scripts/build-and-test.sh plcc-ng` | Build and smoke-test the standard image. Use `plcc-ng-full` for the full image (20–40 min). |
| `bash scripts/reuse.sh lint` | Check licensing with REUSE. |
| [bin/install/claude-imports.bash](bin/install/claude-imports.bash) | Approve [AGENTS.md](AGENTS.md)'s imports from `../dev` in `~/.claude.json`. Run by the devcontainer on creation. Idempotent. |
