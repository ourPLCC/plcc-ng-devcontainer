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

1. A PR merges to `main` with a Conventional Commit message: `fix:` → patch,
   `feat:` → minor, `feat:` with a `BREAKING CHANGE:` footer → major, and
   `ci:`/`docs:`/`chore:`/`test:` → no release.

   Use the footer, not `feat!:`. The Angular preset does not parse the `!`
   shorthand, so `feat!:` alone yields **no release** while CI stays green.
   For the same reason, prefer a merge commit over squash on a major: squash
   can drop the footer and silently downgrade the release to a minor.
2. The **Release** workflow's `plan` job asks semantic-release, in dry-run,
   whether this commit will release anything. On `main` the only reason to
   build is to feed a release — PR CI has already verified the code.
3. The `build` job builds both image variants on native amd64 and arm64
   runners, smoke-tests each, and pushes per-arch candidate tags
   `{sha}-amd64` / `{sha}-arm64` — **only when `plan` said a release is
   coming**. Otherwise its steps are skipped and the job finishes in
   seconds. The job itself always runs, so its check is always reported.
4. The `release` job runs semantic-release for real: computes the next
   version, tags the repo, updates `CHANGELOG.md`, creates the GitHub
   release.
5. The `publish-images` job stitches the candidate tags into multi-arch
   manifests tagged `X.Y.Z`, `X.Y`, `X`, and `latest` for both images. It is
   skipped when nothing was released.
6. The `publish-feature` job runs `devcontainer features publish` for
   `src/`; it publishes only if `devcontainer-feature.json`'s `version` has
   not been published before, so it is a no-op on most releases.

Image versions come from semantic-release; the **feature is versioned
independently** — bump the `version` field in
`src/plcc-ng/devcontainer-feature.json` in the same PR as any feature change.

## Weekly plcc-ng bump

`check-plcc-ng-release.yml` runs Mondays 09:00 UTC (and via **Run workflow**).
It compares the latest PyPI release of plcc-ng against the version pinned in
`images/plcc-ng/.devcontainer/devcontainer.json` and opens a PR when they
differ. Review CI and merge if green.

**The release type is derived, not fixed.** A new plcc-ng *major* opens a
`feat:` PR carrying a `BREAKING CHANGE:` footer, so the images release as a
major too; anything else opens a `fix:`. This matters because
`docs/choosing-your-image.md` tells courses to pin the major tag for a term —
shipping a new major of the tool under the same `:N` would break that promise
mid-semester.

One PR updates every place the version appears:

| File | What changes |
|---|---|
| `images/*/.devcontainer/devcontainer.json` | the pinned feature version, in both variants |
| `test/plcc-ng/scenarios.json` | the pinned-version test scenario |
| `test/plcc-ng/pinned_version.sh` | `EXPECTED_VERSION`, so the assertion matches its own scenario |
| `src/plcc-ng/devcontainer-feature.json` | `proposals`, the description example, and a patch bump of the feature's own version so the edit publishes |
| `docs/choosing-your-image.md` | the `{ "version": "X.Y.Z" }` example |

On a **major** bump it additionally retags the fully qualified image
references in `README.md`, `devcontainer.json` and
`docs/choosing-your-image.md` from `:N` to `:M`, and the PR body asks a human
to update the tag-guidance prose — that wording names both the new major and
the one being left behind, so it cannot be rewritten mechanically.
`ghcr.io/ourplcc/features/plcc-ng:1` is deliberately never retagged: it
tracks the feature's own version, not plcc-ng's.

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
   pull request before merging, and require exactly one status check:
   **`ci-gate`**. Do not require job names such as `build (plcc-ng)` —
   Actions posts one check per job, so a matrix rename or a new job leaves
   the ruleset waiting on a name nothing reports, and the PR hangs on
   "Expected" forever with every real check green. `ci-gate` depends on the
   other jobs and its name never changes. Add the
   release bot's GitHub App to the ruleset's bypass list, or semantic-release's
   push will be rejected same as any other direct push — the App only
   appears as a selectable bypass actor once its installation has been
   granted access to this specific repo (step 2).
4. Merge any PR with a `feat:` commit → first release publishes everything.
5. In the ourPLCC org package settings, make these GHCR packages **public**:
   `devcontainers/plcc-ng`, `devcontainers/plcc-ng-full`,
   `features/plcc-ng`. (New GHCR packages default to private.)

## Housekeeping

- Per-arch candidate tags (`{sha}-amd64`/`{sha}-arm64`) accumulate in GHCR,
  as do `pr-{N}` tags from PR builds. They are harmless; delete old ones via
  the package settings UI if clutter bothers you. Candidates are only
  produced for commits that actually release — infra-only merges skip the
  build entirely (see `plan`, above), so they no longer leave orphans.
- Renovate/Dependabot are not configured; the base image and language
  feature versions float by design (`base:ubuntu`, Node `lts`), pinned only
  where reproducibility matters (plcc-ng, Java major, Python minor).
