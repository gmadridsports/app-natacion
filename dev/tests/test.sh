#!/usr/bin/env /bin/sh


  declare -a artifact_files=("dev/tests/artifact_files_android.txt" "dev/tests/artifact_files_ios.txt")
   for artifact_filepath in "${artifact_files[@]}"; do
     echo $artifact_filepath
    for local_filepath in $(<${artifact_filepath}); do
      file_name=$(basename "${local_filepath}")

      echo "Copying ${file_name}"
#      scp -i "${SSH_PRIVATE_KEY_PATH}" "${SSH_USER_SRC_PATH}/${file_name}" "${local_filepath}"
    done
  done
