#!/usr/bin/env /bin/bash
SSH_USER_SRC_PATH=$(cat dev/tests/env/ssh-user-src-path)
SSH_PRIVATE_KEY_PATH=$(cat dev/tests/env/ssh-private-key-path)
BRANCH_NAME=${GITHUB_HEAD_REF:-$(git branch --show-current)}
LOCAL_RSYNCED_BASEDIR_PULL="/tmp/gmadrid-natacion-test-artifacts-pull"
LOCAL_RSYNCED_PUSH_BASEDIR="/tmp/gmadrid-natacion-test-artifacts-push"
REMOTE_ARTIFACT_BUILD_TIMESTAMP="$(cat dev/tests/artifact_build_timestamp.info)"
REMOTE_ARTIFACT_BUILD_UUID="$(cat dev/tests/artifact_build_uuid.info)"
REMOTE_ARTIFACT_BUILD_DIR="${REMOTE_ARTIFACT_BUILD_TIMESTAMP}-${REMOTE_ARTIFACT_BUILD_UUID}"
REMOTE_ARTIFACT_FULL_PATH="${SSH_USER_SRC_PATH}/${BRANCH_NAME}/${REMOTE_ARTIFACT_BUILD_DIR}"
LOCAL_RSYNCED_PUSH_DIR="${LOCAL_RSYNCED_PUSH_BASEDIR}/${BRANCH_NAME}/${REMOTE_ARTIFACT_BUILD_DIR}"
LOCAL_RSYNCED_PULL_DIR="${LOCAL_RSYNCED_BASEDIR_PULL}/${REMOTE_ARTIFACT_BUILD_DIR}"

if [ "$1" = "pull" ]; then
  echo "Pulling the latest test artifact info from the server..."

  check_latest_test_artifact_on_branch_output=$(dev/tests/check_latest_test_artifact_on_branch.sh)
  check_latest_test_artifact_on_branch_result="${?}"

  if [[ $check_latest_test_artifact_on_branch_result -eq 1 ]]; then
    echo "${check_latest_test_artifact_on_branch_output}. Skipping... 🫥"
    exit 0
  fi

  echo "Copying the integration tests from the server... 🚀"

  rm -R ${LOCAL_RSYNCED_BASEDIR_PULL}
  mkdir -p ${LOCAL_RSYNCED_BASEDIR_PULL}

  rsync -rahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${REMOTE_ARTIFACT_FULL_PATH} ${LOCAL_RSYNCED_BASEDIR_PULL} || {
    echo "No remote artifacts found for this commit. Skipping... 🫥️";
    exit 0;
  }

  declare -a artifact_files_list=("dev/tests/artifact_files_android.txt" "dev/tests/artifact_files_ios.txt")
  for artifact_filepaths in "${artifact_files_list[@]}"; do
    for local_filepath in $(<${artifact_filepaths}); do
      file_name=$(basename "${local_filepath}")
      dir_path=$(dirname "${local_filepath}")

      echo "Copying ${file_name}"
      mkdir -p "${dir_path}"
      cp "${LOCAL_RSYNCED_PULL_DIR}/${local_filepath}" "${local_filepath}"
    done
  done

  echo "Cleaning up tmp dir..."
  rm -R ${LOCAL_RSYNCED_BASEDIR_PULL}

  echo "Done."
  exit 0
fi

if [ "$1" = "push" ]; then
  echo "Copying the integration tests to the server... 🚀"

  rm -R ${LOCAL_RSYNCED_PUSH_BASEDIR}
  mkdir -p ${LOCAL_RSYNCED_PUSH_BASEDIR}

  declare -a artifact_files_list=("dev/tests/artifact_files_android.txt" "dev/tests/artifact_files_ios.txt")
   for artifact_filepaths in "${artifact_files_list[@]}"; do
    for local_filepath in $(<${artifact_filepaths}); do
      file_name=$(basename "${local_filepath}")
      dir_path=$(dirname "${local_filepath}")
      mkdir -p "${LOCAL_RSYNCED_PUSH_DIR}/${dir_path}"
      cp "${local_filepath}" "${LOCAL_RSYNCED_PUSH_DIR}/${local_filepath}"
      echo "Copying ${file_name}'"
    done
  done

  mkdir -p "${LOCAL_RSYNCED_PUSH_DIR}/dev/tests"
  cp dev/tests/artifact_files_latest_build.info "${LOCAL_RSYNCED_PUSH_DIR}/dev/tests/artifact_files_latest_build.info"
  cp dev/tests/artifact_build_timestamp.info "${LOCAL_RSYNCED_PUSH_DIR}/dev/tests/artifact_build_timestamp.info"

  echo "Syncing to the remote..."
  rsync -rahP -e "ssh -i '${SSH_PRIVATE_KEY_PATH}'" ${LOCAL_RSYNCED_PUSH_BASEDIR}/ ${SSH_USER_SRC_PATH}/ || exit 1
  echo "Synced."

  echo "Cleaning up tmp push dir..."
  rm -R ${LOCAL_RSYNCED_PUSH_BASEDIR}

  echo "Done."
  exit 0;
fi

echo "available commands: pull, push"
exit 1;