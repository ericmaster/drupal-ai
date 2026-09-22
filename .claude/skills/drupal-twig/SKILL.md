---
name: drupal-twig
description: Drupal Twig templates — best practices, auto-escaping, translation, library attaching, debugging, and SDC components.
---

# Drupal Twig Best Practices

## Core Rules

- Variables are auto-escaped — never use `|escape` unless you know the source
- Use `{% trans %}` for all user-facing strings
- Use `{{ attach_library() }}` for CSS/JS — never inline
- Never access services or run queries in Twig

## Translation

```twig
{# Simple string #}
{% trans %}Hello world{% endtrans %}

{# With variable #}
{% trans %}Hello {{ name }}{% endtrans %}

{# Plural #}
{% trans %}
  @count item
{% plural count %}
  @count items
{% endtrans %}
```

## Attaching Libraries

```twig
{{ attach_library('my_module/my-library') }}
{{ attach_library('mytheme/component-name') }}
```

## Safe Markup

```twig
{# Render arrays and Markup objects are rendered by Drupal; do not add |raw. #}
{{ content.body }}
{{ content }}

{# Render a single field #}
{{ content.field_image }}

{# Render with a specific view mode #}
{{ node|view('teaser') }}
```

Never use `|raw` to force a render array or field to display. Use a render array, a field render
element, or a deliberately sanitized `MarkupInterface` value. Only use `|raw` when the value's
trusted/sanitized origin is explicit and reviewed.

## Debugging

```twig
{# Dump variables (requires Twig debug enabled) #}
{{ dump(content) }}
{{ dump(node) }}
{{ dump(_context|keys) }}
```

## Common Variables

```twig
{# Node template #}
{{ node.title.value }}
{{ node.bundle() }}
{{ node.id() }}
{{ node.isPublished() }}

{# Check if field is set #}
{% if content.field_image|render %}
  {{ content.field_image }}
{% endif %}

{# Field items loop #}
{% for item in node.field_tags %}
  {{ item.entity.name.value }}
{% endfor %}
```

## SDC Components (Drupal 10.3+)

```twig
{# Use a component #}
{% include 'mytheme:button' with {
  label: 'Click me',
  url: path('entity.node.canonical', {node: node.id()}),
  variant: 'primary',
} %}
```

## Template Suggestions Hook

```php
#[Hook('theme_suggestions_node_alter')]
public function themeSuggestionsNodeAlter(array &$suggestions, array $variables): void {
  $node = $variables['elements']['#node'];
  $view_mode = $variables['elements']['#view_mode'];
  $suggestions[] = 'node__' . $node->bundle() . '__' . $view_mode;
}
```
