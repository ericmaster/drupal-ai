---
name: drupal-fields
description: Drupal fields — field types, widgets, formatters, drush field:create, field storage/config, and accessing single-value and multi-value field values in PHP code.

---

# Drupal Fields

## Creating Fields (Drush — CLI First)

**Always use `ddev drush field:create` instead of manually creating field config files.**

```bash
# Interactive (recommended first time)
ddev drush field:create

# Non-interactive
ddev drush field:create node article \
  --field-name=field_subtitle \
  --field-label="Subtitle" \
  --field-type=string \
  --field-widget=string_textfield \
  --is-required=0 \
  --cardinality=1

# Reference field
ddev drush field:create node article \
  --field-name=field_tags \
  --field-label="Tags" \
  --field-type=entity_reference \
  --field-widget=entity_reference_autocomplete \
  --cardinality=-1 \
  --target-type=taxonomy_term

# Image field
ddev drush field:create node article \
  --field-name=field_image \
  --field-label="Image" \
  --field-type=image \
  --field-widget=image_image \
  --is-required=0 \
  --cardinality=1
```

## Managing Fields

```bash
# List all fields on a content type
ddev drush field:info node article

# Delete a field
ddev drush field:delete node.article.field_subtitle

# Discover available types/widgets/formatters
ddev drush field:types
ddev drush field:widgets
ddev drush field:formatters
```

## Export After Creating Fields

```bash
# Always export config after CLI changes
ddev drush config:export -y
```

## Custom Field Type (Plugin)

```bash
ddev drush generate plugin:field:type
ddev drush generate plugin:field:formatter
ddev drush generate plugin:field:widget
```

## Accessing Field Values in Code

```php
// Single value
$value = $entity->get('field_name')->value;

// Entity reference
$referenced = $entity->get('field_ref')->entity;

// Multi-value
foreach ($entity->get('field_multi') as $item) {
  $value = $item->value;
}
```
