#!/usr/bin/env /bin/bash

echo "Remote scp test artifacts path:"
echo ""
DEFAULT_USER_SRC_PATH=$(<dev/tests/env/ssh-user-src-path)
read -p "Enter the remote scp test artifacts path [${DEFAULT_USER_SRC_PATH}]: " -r SSH_USER_SRC_PATH_INPUT
echo "${SSH_USER_SRC_PATH_INPUT:-$DEFAULT_USER_SRC_PATH}" > dev/tests/env/ssh-user-src-path

DEFAULT_PRIVATE_KEY_PATH=$(<dev/tests/env/ssh-private-key-path)
read -p "Enter the private ssh key path [${DEFAULT_PRIVATE_KEY_PATH}]: " -r SSH_PRIVATE_KEY_PATH_INPUT
echo "${SSH_PRIVATE_KEY_PATH_INPUT:-${DEFAULT_PRIVATE_KEY_PATH}}" > dev/tests/env/ssh-private-key-path

DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD=$(cat dev/tests/env/supabase-admin-local-test-password)
read -p "Enter the Supabase admin local test password [${DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD}]: " -r SUPABASE_ADMIN_TEST_PASSWORD_INPUT
echo "${SUPABASE_ADMIN_TEST_PASSWORD_INPUT:-${DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD}}" > dev/tests/env/supabase-admin-local-test-password

DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD=$(cat dev/tests/env/supabase-admin-test-test-password)
read -p "Enter the Supabase admin test env test password [${DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD}]: " -r SUPABASE_ADMIN_TEST_PASSWORD_INPUT
echo "${SUPABASE_ADMIN_TEST_PASSWORD_INPUT:-${DEFAULT_SUPABASE_ADMIN_TEST_PASSWORD}}" > dev/tests/env/supabase-admin-test-test-password

# todo socio-xx-xx execute the test framework.sql and add the test user
# todo socio-xx-xx add test resources on the storage automatically

echo "Done."