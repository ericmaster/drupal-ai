---
name: drupal-security
description: Drupal security for routes, controllers, forms, and queries. Add route permissions, access checks, CSRF protection, XSS prevention, SQL injection prevention, and secure file upload validation.
---

# Drupal Security

## Critical Security Patterns

### SQL Injection Prevention

**NEVER concatenate user input into queries:**

```php
// VULNERABLE - SQL injection
$query = "SELECT * FROM users WHERE name = '" . $name . "'";
$result = $connection->query($query);

// SAFE - parameterized query
$result = $connection->select('users', 'u')
  ->fields('u')
  ->condition('name', $name)
  ->execute();

// SAFE - placeholder
$result = $connection->query(
  'SELECT * FROM {users} WHERE name = :name',
  [':name' => $name]
);
```

### XSS Prevention

**Always escape output. Trust the render system:**

```php
// VULNERABLE - raw HTML output
return ['#markup' => $user_input];
return ['#markup' => '<div>' . $title . '</div>'];

// SAFE - plain text (auto-escaped)
return ['#plain_text' => $user_input];

// SAFE - use proper render elements
return [
  '#type' => 'html_tag',
  '#tag' => 'div',
  '#value' => $title,  // Escaped automatically
];

// SAFE - Twig auto-escapes
{{ variable }}  // Escaped
{{ variable|raw }}  // DANGEROUS - only for trusted HTML
```

**For admin-only content:**
```php
use Drupal\Component\Utility\Xss;

// Filter but allow safe HTML tags
$safe = Xss::filterAdmin($user_html);
```

Note: Never pass untrusted user input into `#markup`. Prefer `#plain_text`, Twig auto-escaping, or safe render elements.

### Access Control

**Always verify permissions:**

```php
// In routing.yml
my_module.admin:
  path: '/admin/my-module'
  requirements:
    _permission: 'administer my_module'  # Required!

// In code
if (!$this->currentUser->hasPermission('administer my_module')) {
  throw new AccessDeniedHttpException();
}

// Entity queries - check access!
$query = $this->entityTypeManager
  ->getStorage('node')
  ->getQuery()
  ->accessCheck(TRUE)  // CRITICAL - never FALSE unless intentional
  ->condition('type', 'article');
```

### CSRF Protection

Forms automatically include CSRF tokens. For custom AJAX:

```php
// Include token in AJAX requests
$build['#attached']['drupalSettings']['myModule']['token'] =
  \Drupal::csrfToken()->get('my_module_action');
```
Note: Prefer dependency injection over direct `\Drupal::service()` or `\Drupal::` calls in classes.

```php
// Validate in controller
if (!$this->csrfToken->validate($token, 'my_module_action')) {
  throw new AccessDeniedHttpException('Invalid token');
}
```

### File Upload Security

```php
use Drupal\file\Validation\FileValidatorInterface;
use Drupal\file\FileInterface;
use Symfony\Component\Validator\ConstraintViolationListInterface;

final class UploadValidator {

  // Inject file.validator into the class constructor.
  public function __construct(private readonly FileValidatorInterface $fileValidator) {}

  public function validateUpload(FileInterface $file): ConstraintViolationListInterface {
    $validators = [
      'FileExtension' => ['extensions' => 'pdf doc docx'],
      'FileSizeLimit' => ['fileLimit' => 25 * 1024 * 1024],
    ];

    return $this->fileValidator->validate($file, $validators);
  }
}
```

`FileValidator` also applies the `FileExtensionSecure` constraint after the supplied constraints
pass. For images, add `FileIsImage` and dimension constraints as appropriate. Do not teach the
removed `file_validate_*()` functions or invent a `FileSecurity` validator; use Drupal validation
constraints and reject files when the returned violation list is not empty.

### Sensitive Data

```php
// NEVER log sensitive data
$this->logger->info('User @user logged in', ['@user' => $username]);
// NOT: $this->logger->info('Login: ' . $username . ':' . $password);

// NEVER expose in error messages
throw new \Exception('Database error');  // Generic
// NOT: throw new \Exception('Query failed: ' . $query);

// Use environment variables for secrets
$api_key = getenv('MY_API_KEY');
// NOT: $api_key = 'hardcoded-secret-key';
```

## Red Flags to Watch For

When you see these patterns, **immediately warn**:

| Pattern | Risk | Fix |
|---------|------|-----|
| String concatenation in SQL | SQL injection | Use query builder |
| `#markup` with variables | XSS | Use `#plain_text` |
| `accessCheck(FALSE)` | Access bypass | Use `accessCheck(TRUE)` |
| Missing `_permission` in routes | Unauthorized access | Add permission |
| Custom controller with no access check | Unauthorized access | Add route permission or access callback |
| `{{ var\|raw }}` in Twig | XSS | Remove `\|raw` |
| Hardcoded passwords/keys | Credential exposure | Use env vars |
| `eval()` or `exec()` | Code injection | Avoid entirely |
| `unserialize()` on user data | Object injection | Use JSON |
| Missing CSRF validation in custom endpoints | CSRF attack | Validate token using csrf_token service |
| File upload without validation | Malicious file upload | Validate extension, size, and MIME type |
| Direct `\Drupal::` usage in classes | Hard to test / bad practice | Use dependency injection |
| Logging sensitive data | Information disclosure | Mask or avoid logging sensitive fields |
