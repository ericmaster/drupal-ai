---
name: drupal-hooks
description: Drupal 11.1+ OOP and procedural hooks - hook_form_alter, hook_node_presave, hook_theme, #[Hook] attribute, 11.2+ hook ordering, and when to use hooks vs event subscribers.
---

# Drupal Hooks (Drupal 11.1+)

## OOP Hooks (Preferred)

| | |
|---|---|
| **Location** | `src/Hook/MyModuleHooks.php` |
| **Namespace** | `Drupal\my_module\Hook` |
| **Auto-registered** | Drupal 11.1+ when the class/method uses `#[Hook]` |
| **DI support** | Constructor injection |
| **Testable** | Yes — instantiate directly, inject mocks |

## Example (Best Practice)

```php
<?php

namespace Drupal\my_module\Hook;

use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Session\AccountProxyInterface;
use Drupal\Core\StringTranslation\StringTranslationTrait;
use Drupal\node\NodeInterface;

final class MyModuleHooks {

  use StringTranslationTrait; // Provides $this->t().

  public function __construct(
    private readonly AccountProxyInterface $currentUser,
  ) {}

  /**
   * Implements hook_form_node_article_form_alter().
   *
   * Prefer targeted form hooks over generic form_alter — they only fire for
   * the specific form ID and avoid unnecessary processing.
   */
  #[Hook('form_node_article_form_alter')]
  public function formNodeArticleFormAlter(array &$form, FormStateInterface $form_state): void {
    $form['title']['#title'] = $this->t('Article title');
  }

  /**
   * Implements hook_form_alter().
   *
   * Use only when acting on multiple forms or the form ID is unknown at
   * development time. Check $form_id explicitly.
   */
  #[Hook('form_alter')]
  public function formAlter(array &$form, FormStateInterface $form_state, string $form_id): void {
    if ($form_id === 'node_page_form') {
      $form['title']['#description'] = $this->t('Enter a descriptive page title.');
    }
  }

  #[Hook('node_presave')]
  public function nodePresave(NodeInterface $node): void {
    if ($node->getType() === 'article') {
      // Example: stamp the current user's ID on save.
      $node->set('uid', $this->currentUser->id());
    }
  }

  #[Hook('theme')]
  public function theme(): array {
    return [
      'my_template' => [
        'variables' => ['content' => NULL],
      ],
    ];
  }

}
```

> **Note:** If a hook is not executed, verify the attribute, namespace, cache rebuild, and module
> discovery. `src/Hook/` is the recommended location. Attributed hook classes are autowired by
> Drupal; classes that are not attributed or need explicit overrides may still be registered in
> `services.yml`.

## services.yml

| Scenario | Required? |
|---|---|
| Attributed class in `src/Hook/`, namespace `Drupal\my_module\Hook` | No — auto-registered (Drupal 11.1+) |
| Class outside `src/Hook/` (e.g. a custom service) | Yes — register manually |

When registration is needed — autowire resolves constructor dependencies by type hint:

```php
namespace Drupal\my_module\Service;

use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Session\AccountProxyInterface;

final class MyCustomService {

  public function __construct(
    private readonly AccountProxyInterface $currentUser,
  ) {}

  #[Hook('form_alter')]
  public function formAlter(...): void {
    // ...
  }

}
```

```yaml
services:
  Drupal\my_module\Service\MyCustomService:
    autowire: true
```

## Procedural Hooks (.module)

Auto-discovered via `my_module_hook_name()` naming. They remain required for legacy meta hooks and
the install, update, schema, and uninstall hook families. Hooks implemented by themes remain
procedural. A module's runtime `hook_theme()` implementation may use `#[Hook('theme')]`. For runtime
hooks in new Drupal 11.1+ code, prefer the OOP form. Use `LegacyHook` when an attribute
implementation must also support older Drupal versions.

## Hook Ordering (Drupal 11.2+)

Use the `order` parameter when one implementation must run before or after a specific module or
class/method. The order target must be explicit:

```php
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Hook\Order\OrderBefore;

#[Hook('node_presave', order: new OrderBefore(modules: ['other_module']))]
public function nodePresave(NodeInterface $node): void {
  // ...
}
```

Use ordering sparingly. Prefer independent behavior when a hook implementation does not need a
cross-module execution dependency.

## Hooks vs Event Subscribers

| Use Hooks When | Use Event Subscribers When |
|---|---|
| `form_alter`, entity hooks, theme hooks | reacting to dispatched Symfony events |
| extending Drupal core/contrib behavior | PSR-14 / decoupled systems |
| working with existing Drupal APIs | building loosely coupled logic |

> OOP hooks in `src/Hook/` are fully testable — instantiate the class directly and inject mocked dependencies.

## RULES (IMPORTANT)

- ALWAYS prefer OOP hooks in `src/Hook/` for new implementations
- Do not add a procedural runtime hook when an OOP hook is supported and the project targets Drupal 11.1+.
- Do not refactor procedural-only install, update, schema, or uninstall hooks to OOP hooks.
- Keep theme implementations procedural; do not confuse them with a module's `hook_theme()` implementation.
- When reviewing a procedural hook, first check whether the project needs backwards compatibility.
