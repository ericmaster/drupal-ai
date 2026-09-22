---
title: "Drupal 11.4.7 Guidance Snapshot"
type: research
status: active
confidence: strong
sources:
  - "https://git.drupalcode.org/api/v4/projects/project%2Fdrupal/repository/tags?search=11.4"
  - "https://git.drupalcode.org/project/drupal/-/raw/11.4.7/core/composer.json"
  - "https://git.drupalcode.org/project/drupal/-/raw/11.4.7/core/lib/Drupal/Core/Hook/Attribute/Hook.php"
  - "https://git.drupalcode.org/project/drupal/-/raw/11.4.7/core/modules/file/src/Validation/FileValidator.php"
  - "https://git.drupalcode.org/project/drupal/-/raw/11.4.7/core/lib/Drupal/Core/Render/MainContent/HtmxRenderer.php"
  - "https://git.drupalcode.org/project/drupal/-/raw/11.4.7/core/tests/Drupal/KernelTests/KernelTestBase.php"
  - "https://www.drupal.org/docs/develop/theming-drupal/using-single-directory-components"
last_checked: 2026-09-22
---

# Drupal 11.4.7 Guidance Snapshot

This is the current Drupal API and tooling baseline used by this repository. It is a versioned
research takeaway, not a replacement for the Drupal API documentation. Recheck version-bound claims
when Drupal core or a project dependency changes.

## Current Baseline

- Drupal 11.4.7 is the latest 11.x tag observed on 2026-09-22; Drupal 12.0.0-alpha1 is also present.
- Drupal 11.4.7 requires PHP 8.3 or newer. Project examples should not assume PHP 8.2 is sufficient.
- This repository targets Drupal 11.x and should avoid APIs already deprecated for Drupal 12.

## API Rules

- OOP hooks use the `Drupal\Core\Hook\Attribute\Hook` attribute. The attribute API and automatic
  registration are available in Drupal 11.1+; Drupal 11.2 adds hook ordering. Keep the recommended
  `src/Hook/` location for discoverability.
- Procedural-only hooks include legacy meta hooks and the install, update, schema, and uninstall
  families. Hooks implemented by themes remain procedural, while a module's runtime `hook_theme()`
  implementation may use `#[Hook('theme')]`. Use `LegacyHook` when an attribute implementation must
  remain compatible with older Drupal versions.
- Plugins use PHP attributes for new code. Annotation examples are legacy migration material only.
- File validation uses validator constraints such as `FileExtension` and `FileSizeLimit`. Drupal also
  applies `FileExtensionSecure` after the supplied constraints pass; do not teach removed
  `file_validate_*()` functions or invent a `FileSecurity` validator.
- File operations should use the `Drupal\Core\File\FileExists` enum, for example `FileExists::Replace`,
  instead of the deprecated `FileSystemInterface::EXISTS_*` constants.

## Frontend and HTMX

- Single Directory Components are part of Drupal core's render system from Drupal 10.3 onward.
- Drupal 11.3+ ships HTMX 2.0.4. `core/htmx` is the vendor library; `core/drupal.htmx` is Drupal's
  integration bridge and depends on the vendor library.
- `_htmx_route` and the `drupal_htmx` wrapper format use `HtmxRenderer`. The response is a complete
  HTML document assembled for HTMX processing, not a bare fragment with no document shell.
- Render arrays and cacheability metadata remain the source of truth for HTMX responses. Do not use
  Twig `|raw` as a shortcut for render arrays.

## Testing and Tooling

- Kernel tests extending `KernelTestBase` must use `#[RunTestsInSeparateProcesses]` on Drupal 11.3+
  code; omitting it is deprecated and becomes an exception in Drupal 12.
- Do not install the `system` `sequences` table in new kernel tests; that call is deprecated and
  removed in Drupal 12.
- Use `drupal/core-dev` for core development tooling when a project needs the full Drupal test and
  coding-standard stack. Run project commands through the project's container wrapper, such as DDEV.
- Treat performance and security checks as read-only by default. Enabling modules or writing active
  configuration requires an explicit, separately reviewed change.

## Official References

- [Drupal API documentation](https://api.drupal.org/api/drupal/11.x)
- [Drupal release tags](https://git.drupalcode.org/project/drupal/-/tags)
- [Drupal Single Directory Components](https://www.drupal.org/docs/develop/theming-drupal/using-single-directory-components)
- [Drupal deprecation policy](https://www.drupal.org/about/core/policies/core-change-policies/drupal-deprecation-policy)
- [Drupal change records](https://www.drupal.org/list-changes/drupal)
