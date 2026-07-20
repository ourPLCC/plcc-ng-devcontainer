# plcc-ng-devcontainer

Prebuilt [devcontainer](https://containers.dev/) images and a devcontainer
feature for [plcc-ng](https://github.com/ourPLCC/plcc-ng) — for use in courses
and assignments on GitHub Codespaces or VS Code.

## Quick Start

Add a `.devcontainer/devcontainer.json` to your project:

```json
{
  "name": "My PLCC-NG Project",
  "image": "ghcr.io/ourplcc/devcontainers/plcc-ng:1"
}
```

If your course implements language semantics in **Haskell**, use
`ghcr.io/ourplcc/devcontainers/plcc-ng-full:1` instead.

Open the project in [GitHub Codespaces](https://codespaces.github.com) or
[VS Code with the Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
plcc-ng, Python, Java, and JavaScript are ready to use (plus Haskell in `-full`).

**Not sure which image to pick?** See [Choosing your image](./docs/choosing-your-image.md).

## What's published here

| Artifact | Where |
|---|---|
| Standard image (plcc-ng, Python, Java, JavaScript) | `ghcr.io/ourplcc/devcontainers/plcc-ng` |
| Full image (standard + Haskell) | `ghcr.io/ourplcc/devcontainers/plcc-ng-full` |
| Devcontainer feature (installs only plcc-ng) | `ghcr.io/ourplcc/features/plcc-ng` |

## Contributing

1. Fork and clone this repository.
2. Open it in VS Code or Codespaces — the repo's devcontainer includes the
   devcontainer CLI and Docker.
3. Make your changes; test with `bash scripts/build-and-test.sh plcc-ng` and
   `devcontainer features test --project-folder . --features plcc-ng --base-image mcr.microsoft.com/devcontainers/base:ubuntu`.
4. Open a PR — CI tests the feature and builds both images as `pr-{N}` tags.

Use [Conventional Commits](https://www.conventionalcommits.org/):
`fix:` → patch, `feat:` → minor, `feat!:`/`BREAKING CHANGE:` → major.

See the [maintainer guide](./docs/maintainer-guide.md) for how releases work.
