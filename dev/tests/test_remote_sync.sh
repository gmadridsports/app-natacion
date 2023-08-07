#!/usr/bin/env /bin/sh

#SSH_USER_SRC_PATH=$(<dev/tests/env/ssh-user-src-path)
SSH_USER_SRC_PATH_BRANCH="mbertamini@dc991f7.online-server.cloud:/home/mbertamini/gmadrid-natacion/test-artifacts/auth-login"
#SSH_PRIVATE_KEY_PATH=$(<dev/tests/env/ssh-private-key-path)
SSH_PRIVATE_KEY_PATH="~/.ssh/id_github_piensasrv"
#BRANCH_NAME=$(git branch --show-current)
#SSH_USER_SRC_PATH_BRANCH="${SSH_USER_SRC_PATH}/${BRANCH_NAME}"
#SSH_USER_SRC_PATH_BRANCH="mbertamini@dc991f7.online-server.cloud:/home/mbertamini/gmadrid-natacion/test-artifacts/auth-login"
#LOCAL_RSYNCED_BASEDIR_PULL="/tmp/gmadrid-natacion-test-artifacts-pull"
#LOCAL_RSYNCED_PUSH_BASEDIR="/tmp/gmadrid-natacion-test-artifacts-push"
#LOCAL_RSYNCED_PUSH_DIR="${LOCAL_RSYNCED_PUSH_BASEDIR}/${BRANCH_NAME}"
#LOCAL_RSYNCED_PULL_DIR="${LOCAL_RSYNCED_BASEDIR_PULL}/${BRANCH_NAME}"

if [ "$1" = "pull" ]; then
  echo "Pulling the latest test artifact info from the server..."

  rsync -ahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${SSH_USER_SRC_PATH_BRANCH}/artifact_files_latest_build.info dev/tests/artifact_files_latest_build.info.tmp || exit 1

#  if [ $(<dev/tests/artifact_files_latest_build.info) -gt $(<dev/tests/artifact_files_latest_build.info.tmp) ]; then
#    echo "The local test artifacts are newer than the remote ones. Skipping..."
#    exit 1
#    else
#      echo "The remote test artifacts are newer than the local ones. Proceeding..."
#      mv dev/tests/artifact_files_latest_build.info.tmp dev/tests/artifact_files_latest_build.info
#  fi
#
#  echo "Copying the integration tests from the server... 🚀"
#
#  rsync -rahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${SSH_USER_SRC_PATH_BRANCH} ${LOCAL_RSYNCED_BASEDIR_PULL} || exit 1
#
#
#  declare -a artifact_files=("dev/tests/artifact_files_android.txt" "dev/tests/artifact_files_ios.txt")
#   for artifact_filepaths in "${artifact_files[@]}"; do
#    for local_filepath in $(<${artifact_filepaths}); do
#      file_name=$(basename "${local_filepath}")
#
#      echo "Copying ${file_name}"
#      cp "${LOCAL_RSYNCED_PULL_DIR}/${local_filepath}" "${local_filepath}"
#    done
#  done

#  echo "Cleaning up tmp dir..."
#  rm -R ${LOCAL_RSYNCED_BASEDIR_PULL}

  echo "Done."
  exit 0
fi

if [ "$1" = "push" ]; then
  echo "Copying the integration tests to the server... 🚀"

  echo "Pulling the latest test artifact info from the server..."
  rsync -ahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${SSH_USER_SRC_PATH_BRANCH}/artifact_files_latest_build.info dev/tests/artifact_files_latest_build.info.tmp || echo "-1" > dev/tests/artifact_files_latest_build.info.tmp

  if [ $(<dev/tests/artifact_files_latest_build.info) -lt $(<dev/tests/artifact_files_latest_build.info.tmp) ]; then
    echo "The local test artifacts are older than the remote ones. Skipping..."
    exit 1
    else
      echo "The local test artifacts are newer than the remote ones. Proceeding..."
      rm dev/tests/artifact_files_latest_build.info.tmp
  fi

  rm -R ${LOCAL_RSYNCED_PUSH_BASEDIR}
  mkdir -p ${LOCAL_RSYNCED_PUSH_BASEDIR}

  declare -a artifact_files=("dev/tests/artifact_files_android.txt" "dev/tests/artifact_files_ios.txt")
   for artifact_filepaths in "${artifact_files[@]}"; do
    for local_filepath in $(<${artifact_filepaths}); do
      file_name=$(basename "${local_filepath}")
      dir_path=$(dirname "${local_filepath}")
      mkdir -p "${LOCAL_RSYNCED_PUSH_DIR}/${dir_path}"
      cp "${local_filepath}" "${LOCAL_RSYNCED_PUSH_DIR}/${local_filepath}"
      echo "Copying ${file_name}'"
    done
  done

  rsync -rahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${LOCAL_RSYNCED_PUSH_BASEDIR}/ ${SSH_USER_SRC_PATH}/ || exit 1

  echo "Generating the latest test artifact info and syncing with the remote one..."
  rsync -ahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" dev/tests/artifact_files_latest_build.info ${SSH_USER_SRC_PATH_BRANCH}/artifact_files_latest_build.info || exit 1

  echo "Cleaning up tmp push dir..."
  rm -R ${LOCAL_RSYNCED_PUSH_BASEDIR}

  echo "Done."
  exit 0;
fi

echo "available commands: pull, push"
exit 1;