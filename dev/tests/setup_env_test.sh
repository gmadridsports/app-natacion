#!/usr/bin/env /bin/bash

echo "Remote scp test artifacts path:"
echo ""
DEFAULT_USER_SRC_PATH=$(<dev/tests/env/ssh-user-src-path)
read -p "Enter the remote scp test artifacts path [${DEFAULT_USER_SRC_PATH}]: " -r SSH_USER_SRC_PATH_INPUT
echo "${SSH_USER_SRC_PATH_INPUT:-$DEFAULT_USER_SRC_PATH}" > dev/tests/env/ssh-user-src-path

DEFAULT_PRIVATE_KEY_PATH=$(<dev/tests/env/ssh-private-key-path)
read -p "Enter the private ssh key path [${DEFAULT_PRIVATE_KEY_PATH}]: " -r SSH_PRIVATE_KEY_PATH_INPUT
echo "${SSH_PRIVATE_KEY_PATH_INPUT:-${DEFAULT_PRIVATE_KEY_PATH}}" > dev/tests/env/ssh-private-key-path

echo "Done."