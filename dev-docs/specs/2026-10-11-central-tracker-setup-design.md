# Setting up plcc-ng-devcontainer for the central tracker — design

Date: 2026-10-11

## Problem

Work in plcc-ng-devcontainer is tracked in `ourPLCC/dev`, but people
developing this repo cannot reach the tracker from its devcontainer, and
agents here never load the org developer guide. Two specs say what every code
repo needs: the central tracker design
([2026-10-08-199-central-tracker-design.md](../../../plcc-ng/dev-docs/specs/2026-10-08-199-central-tracker-design.md),
"Setup in each code repo") and the org developer docs design
([2026-10-10-org-developer-docs-design.md](../../../dev/dev-docs/specs/2026-10-10-org-developer-docs-design.md),
"What each code repo keeps", "Agent instructions"). plcc-ng and plcc-ng-demo
already follow them.

This repo has no legacy issues to migrate, but it starts further back than
plcc-ng-demo did:

- Its devcontainer has no Claude Code feature and no `~/.claude` volume.
- It has no `AGENTS.md`, `CONTRIBUTING.md`, `dev-docs/`, or
  `.claude/settings.json`.
- The README's "Contributing" section restates org material (commit style).
- Its specs and plans live in `docs/superpowers/`.
- `REUSE.toml` licenses documentation as GFDL through an explicit path list;
  every other file defaults to GPL.

This spec records only what plcc-ng-devcontainer adds to those two specs.
Everything they say that this spec does not override applies.

## Audiences

- **Clients** are students, faculty, and developers who use the published
  images, the feature, and the root `devcontainer.json` template, often on
  Codespaces. Nothing they use changes: not `images/`, `src/`, the root
  template, or `docs/choosing-your-image.md`.
- **Developers of this repo** use its own `.devcontainer/`. Opened in local
  VS Code, it must start and reach the tracker.

## Decision summary

Set the repo up as plcc-ng-demo is, including the Claude Code pieces this repo
lacks, and move the README's contributor material into a new
`CONTRIBUTING.md`. Existing docs stay where they are: `docs/superpowers/` is
frozen history, and new specs go in `dev-docs/specs/`.

The repo's own devcontainer depends on a `../dev` clone on the host, which a
Codespace cannot provide. Developing this repo in Codespaces is therefore no
longer supported, and the docs say so.

Every commit is `chore`, `docs`, or `build(devcontainer)`, so semantic-release
publishes no new image.

## Devcontainer

`.devcontainer/devcontainer.json` keeps its `base:ubuntu` image, its Node and
Docker-in-Docker features, and the `moby: false` comment. It gains:

- **Feature:** `ghcr.io/anthropics/devcontainer-features/claude-code:1.0`.
  `devcontainer-lock.json` is regenerated and committed.
- **`initializeCommand`** (on the host):
  `test -d ../dev || git clone https://github.com/ourPLCC/dev ../dev; git -C ../dev config core.hooksPath .githooks`.
- **`mounts`:**
  - `${localWorkspaceFolder}/../dev` bound at `/workspaces/dev`;
  - a named volume `plcc-ng-devcontainer-claude` at `/home/vscode/.claude`,
    so assistant memory and settings survive a rebuild. Volumes are shared
    across the whole machine, so the name is this repo's own.
- **`containerEnv`:** `BACKLOG_CWD=/workspaces/dev`, and `GIT_CONFIG_COUNT=2`
  with `safe.directory` set to exactly `/workspaces/dev` and
  `${containerWorkspaceFolder}`. Never `*`.
- **`postCreateCommand`**, one `&&` chain so that any failure stops container
  creation:
  1. `sudo chown vscode:vscode /home/vscode/.claude`;
  2. `npm i -g backlog.md@$(cat /workspaces/dev/.backlog-version)`;
  3. `git -C /workspaces/dev status >/dev/null` and
     `git -C ${containerWorkspaceFolder} status >/dev/null`, which fail
     loudly if git refuses either repo as dubious ownership;
  4. `${containerWorkspaceFolder}/bin/install/claude-imports.bash`;
  5. `npm install -g @devcontainers/cli`, as today.
- A comment, like plcc-ng-demo's, explaining the `../dev` mount and the
  volume.

`claude-imports.bash` needs `jq`. If `base:ubuntu` lacks it, step 4 fails
loudly. In that case, install `jq` in `postCreateCommand` rather than switch
images.

## New files

- **`AGENTS.md`** imports `@../dev/ORG-AGENTS.md`, `@../dev/CONTRIBUTING.md`,
  then `@CONTRIBUTING.md`, one per line with nothing after the path. It has no
  repo-specific agent rules yet, so it has no section for them.
- **`bin/install/claude-imports.bash`** is plcc-ng-demo's script with this
  repo's SPDX header added. It finds the repo root from its own location.
- **`.claude/settings.json`** allows `Bash(backlog:*)`.
- **`.gitignore`** gains `.plans/`, with plcc-ng-demo's comment.
- **`REUSE.toml`** adds `AGENTS.md`, `CONTRIBUTING.md`, and `dev-docs/**` to
  the GFDL annotation. The script and `.claude/settings.json` stay under the
  GPL default. `CLAUDE.md` stays listed, because removing it is unrelated
  cleanup.
- **`dev-docs/specs/`** holds this spec.

## Documentation

**`CONTRIBUTING.md`** opens with the line linking the org developer guide,
then:

- **Where this repo differs from the org guide:** nowhere at present.
  `docs/superpowers/specs/` and `docs/superpowers/plans/` predate the org
  guide. They are history, not a deviation: merged specs and plans are
  frozen, so they stay, and new specs go in `dev-docs/specs/`.
- **Development environment:**
  - Open the repo's devcontainer in local VS Code. It clones `ourPLCC/dev` to
    `../dev` and mounts it, which a Codespace cannot do, so this repo is not
    developed in Codespaces. Clients' use of the published images on
    Codespaces is unaffected.
  - The tracker `project` value is `plcc-ng-devcontainer`.
  - Why the container approves `AGENTS.md`'s imports, how to check with
    `/memory`, and the one-import-per-line rule, as plcc-ng-demo's says.
- **Making a change**, moved from the README:
  - Fork, clone, and open the repo in the devcontainer; test; open a PR, and
    CI builds `pr-{N}` images.
  - The release-type rules: `fix` → patch, `feat` → minor, and a
    `BREAKING CHANGE:` footer → major. Also the warning against `feat!:`,
    which is specific to this repo's semantic-release setup and so stays,
    though the org guide covers commit style in general.
  - A link to the maintainer guide for releases.
- **Common commands:** `bin/install/claude-imports.bash`, the feature test,
  `bash scripts/build-and-test.sh <variant>`, and
  `bash scripts/reuse.sh lint`.

**`README.md`:** the "Contributing" section becomes one line pointing to
`CONTRIBUTING.md`. Everything the README says to clients stays.

**`docs/maintainer-guide.md`:** "Local development" says the repo's
devcontainer works inside a Codespace. That changes to local VS Code, with a
link to `CONTRIBUTING.md`. Nothing else changes.

## Out of scope

- Moving `docs/maintainer-guide.md` into `dev-docs/`, where the org guide puts
  release procedures.
- Moving `docs/superpowers/`. Its contents are frozen.
- Sharing the devcontainer setup across repos instead of copying it. That
  would change every code repo and needs its own cross-repo spec.

## Verification

1. `bash scripts/reuse.sh lint` passes.
2. Rebuilding from the branch in local VS Code creates the container without
   errors.
3. Inside the container:
   - `backlog task list --project plcc-ng-devcontainer --plain` works;
   - a `backlog` edit commits in `/workspaces/dev`;
   - `/memory` lists `ORG-AGENTS.md` and both `CONTRIBUTING.md` files.
4. `devcontainer --version`, `docker info`, and the feature test still work
   inside the container.
5. No relative Markdown link in `README.md`, `CONTRIBUTING.md`, `AGENTS.md`,
   or `docs/maintainer-guide.md` points at a missing file.
6. On the PR, `ci-gate` passes, with no image build expected.

## Rejected alternatives

| Alternative | Why not |
| --- | --- |
| Tracker access only, without Claude Code in the container | Agents cannot run here, and anyone who adds Claude Code later meets the silent import skip without the fix; an unexplained difference from the other repos is drift |
| Share the setup through a feature or script in `ourPLCC/dev` | Changes every code repo; a separate cross-repo decision, not this CR |
| Keep this repo's devcontainer working in Codespaces | A Codespace cannot clone and bind-mount `../dev` on the host, and a failed `initializeCommand` stops the container from starting |
| Move `docs/superpowers/` into `dev-docs/` | Edits paths in frozen documents for no change in meaning |
| Leave the README's Contributing section | The org guide counts an unexplained restatement as drift |
| Put this spec in `dev/dev-docs/specs/` | It changes only this repo; plcc-ng-demo's went there because it also changed `migrate/` |
| Share plcc-ng's `~/.claude` volume | Volumes are machine-wide; repos would overwrite each other's memory |
