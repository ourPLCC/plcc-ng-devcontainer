# Choosing Your Image

This guide is for students and faculty setting up a course or assignment
that uses [plcc-ng](https://github.com/ourPLCC/plcc-ng).

## Which image? One question

**Does your course implement language semantics in Haskell?**

- **No** → use the standard image (smaller, faster to start):

  ```json
  {
    "name": "My PLCC-NG Project",
    "image": "ghcr.io/ourplcc/devcontainers/plcc-ng:1"
  }
  ```

- **Yes** → use the full image (adds the Haskell toolchain):

  ```json
  {
    "name": "My PLCC-NG Project",
    "image": "ghcr.io/ourplcc/devcontainers/plcc-ng-full:1"
  }
  ```

Save the snippet as `.devcontainer/devcontainer.json` in your project.

## What's inside

| | `plcc-ng` (3.1 GB) | `plcc-ng-full` (12.4 GB) |
|---|---|---|
| plcc-ng (all `plcc-*` commands) | ✅ | ✅ |
| Python 3.12 | ✅ | ✅ |
| Java 21 | ✅ | ✅ |
| JavaScript (Node LTS) | ✅ | ✅ |
| Haskell (GHC, cabal) | ❌ | ✅ |

Both images are published for amd64 (Codespaces) and arm64 (Apple Silicon).

## Picking a version tag

| Tag | Meaning |
|---|---|
| `latest` | Most recent release |
| `1` | Latest `1.x.x` release |
| `1.2` | Latest `1.2.x` release |
| `1.2.3` | Exact release (immutable) |

**Recommendation for courses:** pin the major tag (e.g. `:1`) for the
semester. You get plcc-ng updates and security patches automatically but are
protected from breaking changes mid-course.

## Custom setups: the feature

If the prebuilt images don't fit (different Java version, extra tools, other
base image), compose your own devcontainer with the plcc-ng feature. It
installs plcc-ng and Python; add language features as needed:

```json
{
  "name": "My Custom PLCC-NG Project",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/ourplcc/features/plcc-ng:1": {},
    "ghcr.io/devcontainers/features/java:1": { "version": "21" }
  }
}
```

The feature's `version` option pins a plcc-ng release from
[PyPI](https://pypi.org/project/plcc-ng/), e.g.
`{ "version": "1.0.0" }`; the default is `latest`.

Note: the first Codespaces start of a feature-composed devcontainer builds
the container from scratch (several minutes). The prebuilt images exist to
avoid exactly that — prefer them when they fit.
