# Maintainer Guide

How the artifacts in this repository are produced, versioned, and released.

## Source layout

| Path | What it is |
|---|---|
| `src/plcc-ng/` | The devcontainer feature (canonical source) |
| `test/plcc-ng/` | Feature tests (`devcontainer features test` layout) |
| `images/plcc-ng/`, `images/plcc-ng-full/` | Prebuilt image definitions (devcontainer.json + label Dockerfile) |
| `test/smoke-test.sh` | In-container smoke test shared by both images |
| `scripts/sync-features.sh` | Copies `src/plcc-ng` into each image workspace (copies are gitignored) |
| `scripts/build-and-test.sh` | Builds one image variant and smoke-tests it — same entry point locally and in CI |

The images consume the **local** feature copy (synced by
`scripts/sync-features.sh`), never the published one — so a PR that changes
the feature is tested end-to-end before anything is published.

## How a release happens

1. A PR merges to `main` with a Conventional Commit message
   (`fix:` → patch, `feat:` → minor, `feat!:` → major).
2. The **Release** workflow's `build` job builds both image variants on
   native amd64 and arm64 runners, smoke-tests each, and pushes per-arch
   candidate tags `{sha}-amd64` / `{sha}-arm64`.
3. The `release` job runs semantic-release: computes the next version, tags
   the repo, updates `CHANGELOG.md`, creates the GitHub release.
4. The `publish-images` job stitches the candidate tags into multi-arch
   manifests tagged `X.Y.Z`, `X.Y`, `X`, and `latest` for both images.
5. The `publish-feature` job runs `devcontainer features publish` for
   `src/`; it publishes only if `devcontainer-feature.json`'s `version` has
   not been published before, so it is a no-op on most releases.

Image versions come from semantic-release; the **feature is versioned
independently** — bump the `version` field in
`src/plcc-ng/devcontainer-feature.json` in the same PR as any feature change.

## Weekly plcc-ng bump

`check-plcc-ng-release.yml` runs Mondays 09:00 UTC: it compares the latest
PyPI release of plcc-ng against the version pinned in both image configs
(`.features["./features/plcc-ng"].version`) and opens a
`fix: update plcc-ng to X.Y.Z` PR when they differ. Review CI and merge if
green. The feature itself is not touched (its default stays `latest`).

## Testing a PR build

CI pushes each PR's images as
`ghcr.io/ourplcc/devcontainers/{plcc-ng,plcc-ng-full}:pr-{N}` (amd64 only)
and comments the tags on the PR. Point any devcontainer.json `image` at one
of those tags to try it.

## Local development

```bash
# Feature tests (fast-ish; builds small test images)
devcontainer features test --project-folder . --features plcc-ng \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu

# Build + smoke test an image variant (plcc-ng-full takes 20–40 min)
bash scripts/build-and-test.sh plcc-ng
bash scripts/build-and-test.sh plcc-ng-full

# REUSE/license lint
bash scripts/reuse.sh lint
```

The repo's own devcontainer (`.devcontainer/devcontainer.json`) includes
Node, Docker-in-Docker, and the devcontainer CLI, so all of the above works
inside a Codespace.

## Initial repository setup (bootstrap)

One-time steps when this repository is first published to GitHub:

1. Create `ourPLCC/plcc-ng-devcontainer` and push `main` (no tags — the
   first release must compute as 1.0.0).
2. Add two repository secrets for the release bot's GitHub App: `APP_ID`
   (the App's numeric ID, from its General settings page) and
   `APP_PRIVATE_KEY` (a private key generated on that same page — the
   full contents of the downloaded `.pem` file). `release.yml` and
   `check-plcc-ng-release.yml` each mint a fresh ~1-hour installation
   token from these at the start of their run
   (`actions/create-github-app-token`), rather than storing a long-lived
   token as a secret — installation tokens can't be pasted once and kept,
   since they expire in about an hour. Required because `GITHUB_TOKEN`
   cannot push semantic-release's changelog commit to the protected
   `main` branch. The App must be installed with access to this repo
   (org Settings → Installations → the App → Configure → Repository
   access) and granted `Contents: Read and write` and `Pull requests:
   Read and write` permissions.
3. Protect `main` with a ruleset (Settings → Rules → Rulesets): require a
   pull request before merging and require the CI status check. Add the
   release bot's GitHub App to the ruleset's bypass list, or semantic-release's
   push will be rejected same as any other direct push — the App only
   appears as a selectable bypass actor once its installation has been
   granted access to this specific repo (step 2).
4. Merge any PR with a `feat:` commit → first release publishes everything.
5. In the ourPLCC org package settings, make these GHCR packages **public**:
   `devcontainers/plcc-ng`, `devcontainers/plcc-ng-full`,
   `features/plcc-ng`. (New GHCR packages default to private.)

## Housekeeping

- Per-arch candidate tags (`{sha}-amd64`/`{sha}-arm64`) accumulate in GHCR.
  They are harmless; delete old untagged/candidate versions occasionally via
  the package settings UI if clutter bothers you.
- Renovate/Dependabot are not configured; the base image and language
  feature versions float by design (`base:ubuntu`, Node `lts`), pinned only
  where reproducibility matters (plcc-ng, Java major, Python minor).
