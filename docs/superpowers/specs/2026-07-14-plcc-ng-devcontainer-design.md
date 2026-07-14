# plcc-ng-devcontainer — Design

**Date:** 2026-07-14
**Status:** Proposed

## Goal

Make it easy and fast for students to use [plcc-ng](https://github.com/ourPLCC/plcc-ng)
in GitHub Codespaces or a local VS Code devcontainer, while letting them add
whichever semantic-implementation language(s) their course uses (Java, Python,
JavaScript, Haskell). Provide:

- **Simplicity:** a one-line `devcontainer.json` for the common cases.
- **Performance:** prebuilt images so Codespaces start without building.
- **Flexibility:** a published devcontainer feature for anyone who wants a
  custom composition.

This repository is a repurposed clone of
[plcc-devcontainer](https://github.com/ourPLCC/plcc-devcontainer) (remote
removed). The original repository remains published and untouched; it will be
archived only after plcc-ng resources are proven and an archival notice has
been advertised well in advance (~6 months).

## Artifacts

This repository defines, builds, tests, and publishes three artifacts to GHCR.

### 1. The `plcc-ng` feature — `ghcr.io/ourplcc/features/plcc-ng`

A [devcontainer feature](https://containers.dev/implementors/features/) that
installs **only plcc-ng**, via `pipx install plcc-ng==<version>` from PyPI.

- **Options:** `version` (string, default `latest`) — the PyPI version to
  install; `latest` installs the newest release.
- **Dependencies:** declares `dependsOn` on
  `ghcr.io/devcontainers/features/python` so it works on any base image.
  Language toolchains are *not* this feature's job — consumers compose the
  official features (`ghcr.io/devcontainers/features/java`, `.../python`,
  `.../node`) and the community Haskell feature
  (`ghcr.io/devcontainers-extra/features/haskell`).
- **Published** as an OCI artifact with
  [devcontainers/action](https://github.com/devcontainers/action) so any
  project can reference it directly.
- **Versioned independently** via the `version` field in
  `devcontainer-feature.json` (the publish action only pushes when it changes).

Replaces the old local-only, git-clone-based `plcc` feature.

### 2. Prebuilt images — `ghcr.io/ourplcc/devcontainers/plcc-ng` and `plcc-ng-full`

Each image is a composition of `mcr.microsoft.com/devcontainers/base:ubuntu`
plus features, built with the devcontainers CLI in a CI matrix (one matrix
entry per image, same workflow):

| Image | Contents | Est. size (on disk) |
|---|---|---|
| `devcontainers/plcc-ng` | plcc-ng, Python, Java, JavaScript (Node) | ~2 GB |
| `devcontainers/plcc-ng-full` | the above + Haskell (GHC toolchain) | ~6–7 GB |

**Why exactly two:** the GHC toolchain (~4–7 GB) dwarfs every other component
(JDK ~0.3 GB, Node ~0.2 GB). Per-language images would save students only
200–500 MB each while tripling the maintenance and documentation surface, and
a Haskell-only image would be nearly the same size as `-full`. Two images
reduce the user decision to one question: *"Does your course use Haskell?"*

**Why namespaced names:** `devcontainers/` in the package path mirrors the
`features/` namespace and the broader ecosystem convention
(`mcr.microsoft.com/devcontainers/base`). It keeps the leaf names short while
reserving bare `ghcr.io/ourplcc/plcc-ng` for a possible future plain CLI image
of the tool itself.

**Pinning:** each image pins an exact plcc-ng version (bumped by the weekly
workflow, below) so releases are reproducible. Both images are built
**multi-arch (amd64 + arm64)** — Codespaces is amd64; local devcontainers on
Apple Silicon need arm64.

### 3. Version tags

Both images use the tag scheme already established by plcc-devcontainer,
driven by semantic-release from conventional commits:

| Tag | Meaning |
|---|---|
| `latest` | most recent release |
| `1` | latest `1.x.x` |
| `1.2` | latest `1.2.x` |
| `1.2.3` | exact release (immutable) |

Both images are built from the same commit and share the same version number.
Courses are advised to pin the major tag. PR builds publish `pr-{N}` tags for
testing, as today.

## CI / release flow

1. PR opened → CI builds both images (and runs feature tests + image smoke
   tests), publishes `pr-{N}` tags.
2. Conventional commit merged to `main` → semantic-release computes the next
   version, tags, updates `CHANGELOG.md` (requires the existing
   `RELEASE_TOKEN` arrangement for the protected branch).
3. Release workflow builds both images multi-arch and pushes all four tag
   forms; publishes the feature if its version changed.
4. A weekly workflow checks PyPI for a new plcc-ng release and opens a
   `fix: update plcc-ng to X.Y.Z` PR (adapted from the existing
   check-plcc-release workflow).

## Testing

- **Feature:** `devcontainer features test` scenarios (installs on a bare
  base image; `version` option pins correctly; `plcc-ng` commands on PATH).
- **Images:** smoke test in CI (adapt `test/test-env.sh`): plcc-ng commands
  run; `java`, `python`, `node` present in both images; `ghc` present in
  `-full`.
- **Size spike:** before finalizing, build both images once and record real
  compressed/uncompressed sizes; the estimates above are provisional.

## Documentation

Two audience-separated documents, replacing the current single README (README
keeps the quick start and links to both):

1. **Choosing your image** (students & faculty). Must answer *"which one
   should I pick and why?"*: the Haskell decision, copy-paste
   `devcontainer.json` per image, the tag table with the
   pin-the-major-for-a-semester recommendation, and a "custom setups" section
   showing how to compose the feature with language features instead.
2. **Maintainer guide** (developers). End-to-end release mechanics:
   conventional commits → semantic-release → matrix build → GHCR tag fan-out;
   how the weekly bump PR works; how the feature is versioned and published
   separately from the images; how to test a PR build via its `pr-{N}` tag.

**Layout convention:** audience-facing documentation lives directly under
`docs/`. Design specs and implementation plans produced during development
live in the superpowers plugin's default locations — `docs/superpowers/specs/`
and `docs/superpowers/plans/` — so the tooling and the repo agree on where
they go.

## Repurposing cleanup

One-time steps when converting this clone:

- Delete inherited local git tags (`git tag -l | xargs git tag -d`) so
  semantic-release starts the new artifact at `1.0.0` instead of continuing
  plcc-devcontainer's version line. Commit history is kept as provenance.
- Reset `CHANGELOG.md`.
- Sweep all `plcc-devcontainer` / `ourPLCC/plcc` references: README,
  workflows, image/feature names, tests. Keep the old specs and plans in
  `docs/superpowers/` as historical record.
- Replace the root `devcontainer.json` template and this repo's own
  `.devcontainer/` to use the new feature/images.

## Out of scope (for now)

- Dev Container Templates (VS Code "Add Dev Container Configuration Files"
  picker entries) — possible later addition.
- Any change to the published plcc-devcontainer repository.
- Codespaces prebuilds guidance for GitHub Classroom (prebuilds are per-repo
  and don't transfer to generated assignment repos; the prebuilt base images
  are the startup-performance mechanism there).
