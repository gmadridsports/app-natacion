#!/usr/bin/env /bin/sh

# todo auth-login continue here
# prompt the user for the path of the file and store into the file located into dev/tests/env/ssh-user-src-path
echo "Remote scp test artifacts path:"
echo "i.e. mbertamini@dc991f7.online-server.cloud:/home/mbertamini/gmadrid-natacion/test-build/"
echo ""
echo "Remote scp path: \c"
read -r SSH_USER_SRC_PATH
echo "${SSH_USER_SRC_PATH}" > dev/tests/env/ssh-user-src-path

echo "Private ssh key path: \c"
read -r SSH_PRIVATE_KEY_PATH
echo "${SSH_PRIVATE_KEY_PATH}" > dev/tests/env/ssh-private-key-path

echo "Done."