#!/bin/bash
set -e

# This script configures those stuff, which can't be configured via GITLAB_OMNIBUS_CONFIG.
# The gitlab-rails console can be started on the host via
# > docker exec -it gitlab gitlab-rails console

gitlab-rails runner - <<EOS
# - disable signup: https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2837
ApplicationSetting.last.update_attribute(:signup_enabled, false)

EOS

echo "Post Reconfigure Script successfully executed"
