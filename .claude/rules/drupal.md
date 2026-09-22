# Drupal Rules

- Prefer DI; avoid `\Drupal::service()` in classes.
- Follow existing module/namespace conventions.
- Prefer placing code in an existing relevant module over creating a new one.
- Use appropriate Drupal patterns and skills/reference material.

## Hooks

- Always implement hooks using the `drupal-hooks` skill.
- Prefer OOP hooks with `#[Hook]` for new runtime hooks on Drupal 11.1+.
- Keep procedural-only hooks procedural: legacy meta hooks and the install, update, schema, and
  uninstall hook families. Hooks implemented by themes remain procedural. A module's runtime
  `hook_theme()` implementation may use `#[Hook('theme')]`.
- Use `LegacyHook` when providing an attribute implementation alongside a procedural compatibility
  implementation.
