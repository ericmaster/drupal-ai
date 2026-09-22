---
name: drush-check
description: Run common Drush checks to verify Drupal site health
---

# Drush Health Check

Run a series of Drush commands to check site health and status.

**Usage:** `/drush-check`

This command takes no arguments. It runs a standard set of health checks on the current Drupal site.

The examples use DDEV. If the project uses another container wrapper, substitute its command prefix.

## Steps

1. Check Drush is available:
   ```bash
   ddev drush status
   ```

2. Check for available updates:
   ```bash
   ddev drush pm:security
   ```

3. Check configuration status:
   ```bash
   ddev drush config:status
   ```

4. Check for pending database updates:
   ```bash
   ddev drush updatedb:status
   ```

5. Check watchdog for recent errors:
   ```bash
   ddev drush watchdog:show --severity=error --count=10
   ```

## Report Findings

Summarize:
- Drupal version and status
- Any security updates needed
- Configuration sync status
- Pending database updates
- Recent errors in logs
