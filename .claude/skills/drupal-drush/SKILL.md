---
name: drupal-drush
description: Drush commands for Drupal — cache, config, module management, generators, field creation, and non-interactive scaffolding for AI-assisted development.
---

# Drush Commands

## Essential Daily Commands

```bash
ddev drush cr                      # Clear all caches
ddev drush cex -y                  # Export configuration
ddev drush cim -y                  # Import configuration
ddev drush updb -y                 # Run database updates
ddev drush en module_name          # Enable a module
ddev drush pmu module_name         # Uninstall a module
ddev drush ws --severity=error     # Watch error logs
ddev drush ws --severity=error --count=20  # Last 20 errors
ddev drush php:eval "code"         # Run PHP inline
ddev drush sql:dump > dump.sql     # Database dump
```

## Code Generators

```bash
ddev drush generate              # List all generators
ddev drush gen module            # Generate module (gen is alias)
ddev drush generate controller
ddev drush generate form-simple
ddev drush generate form-config
ddev drush generate service
ddev drush generate plugin:block
ddev drush generate plugin:field:formatter
ddev drush generate plugin:field:widget
ddev drush generate plugin:field:type
ddev drush generate event-subscriber
ddev drush generate hook
ddev drush generate entity:content
ddev drush generate entity:configuration
ddev drush generate test:unit
ddev drush generate test:kernel
ddev drush generate test:browser
ddev drush generate drush:command-file
```

## Non-Interactive Generation (--answers JSON)

```bash
# Generate module
ddev drush generate module --answers='{
  "name": "My Module",
  "machine_name": "my_module",
  "description": "A custom module",
  "package": "Custom",
  "dependencies": "",
  "install_file": "no",
  "libraries": "no",
  "permissions": "no",
  "event_subscriber": "no",
  "block_plugin": "no",
  "controller": "no",
  "settings_form": "no"
}'

# Generate service
ddev drush generate service --answers='{
  "module": "my_module",
  "service_name": "my_module.helper",
  "class": "HelperService",
  "services": ["entity_type.manager", "logger.factory"]
}'
```

## Field Management

```bash
# Create field (interactive)
ddev drush field:create

# Create field (non-interactive)
ddev drush field:create node article \
  --field-name=field_subtitle \
  --field-label="Subtitle" \
  --field-type=string \
  --field-widget=string_textfield \
  --is-required=0 \
  --cardinality=1

# List fields
ddev drush field:info node article

# Field types/widgets/formatters
ddev drush field:types
ddev drush field:widgets
ddev drush field:formatters

# Delete field
ddev drush field:delete node.article.field_subtitle
```

## Discover Generator Prompts

```bash
# Preview what answers are needed
ddev drush generate module -vvv --dry-run

# Accept all defaults
ddev drush generate module -y
```

## State & Config via CLI

```bash
# State
ddev drush state:get my_module.last_run
ddev drush state:set my_module.feature_enabled 1
ddev drush state:del my_module.last_run

# Config
ddev drush config:get my_module.settings
ddev drush config:set my_module.settings enabled 1
ddev drush config:edit my_module.settings
```

## User Management

```bash
ddev drush user:create testuser --mail="test@example.com" --password="password"
ddev drush user:login                        # One-time login for uid 1
ddev drush user:login --uid=2               # One-time login for uid 2
ddev drush user:role:add editor testuser
ddev drush user:block testuser
ddev drush user:unblock testuser
```

## DDEV Wrapper

```bash
ddev drush cr
ddev drush cex -y
ddev drush generate module --answers='{...}'
ddev drush field:create node article
```

## Debugging Generated Code

Examples assume a `docroot/`-based Drupal project. If your project uses `web/` or another document root, adjust paths accordingly.

```bash
# Syntax check
ddev exec php -l docroot/modules/custom/my_module/src/MyClass.php

# Check service registration
ddev drush devel:services | grep my_module

# Verify class autoloaded
ddev drush php:eval "class_exists('Drupal\my_module\MyClass') ? print 'Found' : print 'Not found';"
```
