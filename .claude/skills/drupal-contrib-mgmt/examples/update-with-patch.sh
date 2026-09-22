#!/bin/bash
# Example: Update audiofield module with D11 compatibility patch

# 1. Merge the patch entries under the existing top-level "extra.patches" object
# in composer.json. Do not append a second root JSON object.
# Validate after editing:
ddev composer validate --strict

# 2. Create local .info.yml patch if needed
cd docroot/modules/contrib/audiofield
git diff audiofield.info.yml > ../../../patches/audiofield-d11-info.patch
cd ../../..

# 3. Update module
ddev composer require drupal/audiofield:^1.13 --with-all-dependencies

# 4. Run database updates
ddev drush updb -y

# 5. Clear cache
ddev drush cr

# 6. Verify fix
ddev drush upgrade_status:analyze audiofield

# 7. Test functionality
# Visit a page that uses audiofield to ensure no fatal errors

# 8. Commit
git add composer.json composer.lock patches/audiofield-d11-info.patch
git commit -m "Update audiofield to 1.13 with D11 compatibility patches

- Added Drupal 11 core_version_requirement support
- Applied patch for file_validate_extensions() deprecation
- Tested: audio upload functionality works correctly"
