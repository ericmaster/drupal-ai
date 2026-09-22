#!/bin/bash
# Example: Upgrade entity_limit from 2.x to 3.x with D11 compatibility

# 1. Check current version
ddev composer show drupal/entity_limit
# Output: drupal/entity_limit 2.0.0

# 2. Search issue queue for known issues
# Visit: https://www.drupal.org/project/issues/entity_limit?categories=All
# Find: Issue #3432063 - Drupal calls should be avoided in classes

# 3. Merge the patch and lenient entries into the existing top-level "extra" object.
# Do not append a second root JSON object to composer.json. Validate after editing:
ddev composer validate --strict

# 4. Create .info.yml patch
cd docroot/modules/contrib/entity_limit
# Manually edit entity_limit.info.yml to add ^11 to core_version_requirement
git diff entity_limit.info.yml > ../../../patches/entity_limit-d11-info.patch
cd ../../..

# 5. Backup database (major version upgrade!)
ddev drush sql:dump > backup-before-entity-limit-3x.sql

# 6. Update to 3.x
ddev composer require drupal/entity_limit:^3.0@beta --with-all-dependencies

# 7. Run database updates
ddev drush updb -y

# 8. Check for errors
ddev drush watchdog:show --severity=Error --count=10

# 9. Clear cache
ddev drush cr

# 10. Run upgrade_status check
ddev drush upgrade_status:analyze entity_limit

# 11. Test functionality
# - Visit entity limit configuration page
# - Test creating content with entity limits
# - Check permissions work correctly

# 12. If successful, commit
git add composer.json composer.lock patches/entity_limit-d11-info.patch
git commit -m "Upgrade entity_limit to 3.0.0-beta1 with D11 compatibility

Breaking changes:
- Updated API methods (see https://www.drupal.org/node/XXXXX)
- New permission system

Applied patches:
- Drupal calls fix (#3432063)
- D11 core version requirement

Tested: All entity limit functionality working correctly"

# 13. If issues occur, rollback:
# git checkout composer.json composer.lock
# ddev composer install
# ddev drush sql:cli < backup-before-entity-limit-3x.sql
# ddev drush cr
