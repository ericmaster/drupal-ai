---
name: testing
description: Testing conventions — framework choice, test location, structure, and naming for this project
---

# Testing Rules

## Framework

Choose the smallest test type that exercises the behavior:

- **Unit** for pure PHP logic with no Drupal bootstrap.
- **Kernel** for services, database operations, entities, hooks, and configuration with a partial
  Drupal bootstrap.
- **Functional** or **FunctionalJavascript** for an installed site and browser-visible behavior.
- **DTT ExistingSite** for integration tests against an existing configured site.

Use the test type already configured by the project; do not force every behavior into ExistingSite.

## Test Location

Follow the project's `phpunit.xml` and existing test layout. Drupal module-local tests commonly live
under `docroot/modules/custom/{module}/tests/src/{Unit,Kernel,Functional,FunctionalJavascript}`;
some projects keep DTT tests under a root `tests/` directory.

```
docroot/modules/custom/my_module/tests/src/Kernel/
└── MyServiceTest.php
```

## Running Tests

```bash
ddev exec vendor/bin/phpunit -c <web-root>/core/phpunit.xml.dist docroot/modules/custom/my_module/tests
```

Filter by group:
```bash
ddev exec vendor/bin/phpunit -c <web-root>/core/phpunit.xml.dist --filter=my_group docroot/modules/custom/my_module/tests
```

## Structure

- Extend the base class for the selected test type.
- Group by module name using `#[Group('my_group')]` in new PHPUnit code.
- Class name ends in `Test`
- Test method names start with `test`

```php
<?php

namespace Drupal\Tests\ExistingSite;

use weitzman\DrupalTestTraits\ExistingSiteBase;

/**
 * Tests for the my_group module.
 *
 */
#[\PHPUnit\Framework\Attributes\Group('my_group')]
final class MyModuleExampleTest extends ExistingSiteBase {

  public function testSomething(): void {
    // ...
  }

}
```

## What to Test

- Functional behavior visible through the site (pages, blocks, forms)
- Content creation and field values
- Access control (who can see/do what)
- Integration points between modules

## What NOT to Test

- Do not use an integration test for internal PHP logic that can be covered by a unit test
- Database schema or entity structure directly
- Things already covered by Drupal core or contrib tests
