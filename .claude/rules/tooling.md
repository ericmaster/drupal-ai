---
name: tooling
description: Tooling conventions for this project — command prefixes and execution environment
---

# Tooling Rules

This project runs inside DDEV. Always prefix the following commands with `ddev` when executing them:

| Command | Run as |
|---------|--------|
| `drush` | `ddev drush` |
| `composer` | `ddev composer` |
| `phpcs` | `ddev phpcs` |
| `phpstan` | `ddev phpstan` |
| PHP binaries (e.g. `vendor/bin/phpunit`) | `ddev exec vendor/bin/phpunit` |

DDEV management commands (`ddev describe`, `ddev start`, `ddev stop`, `ddev restart`) are already DDEV commands — no prefix needed.

These prefixes apply to commands run from the project host. Examples inside an explicit `ssh ...`
remote shell or the `docker-local` skill describe that environment and intentionally use its own
wrapper.

The `ddev phpcs` and `ddev phpstan` forms require matching project-provided DDEV commands. If a
project does not provide them, use the project's documented `ddev exec vendor/bin/...` equivalent.
