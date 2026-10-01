#!/usr/bin/env bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

if git -C "${PROJECT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${PROJECT_DIR}" submodule update --init --recursive
fi

if [[ ! -f "${PROJECT_DIR}/xarm_sdk/cxx/CMakeLists.txt" ]]; then
  echo "The xarm_sdk/cxx submodule is missing. Clone this repository with --recursive." >&2
  exit 1
fi

docker build \
  --build-arg ROS_DISTRO=jazzy \
  --tag "${IMAGE_NAME}" \
  "$@" \
  "${PROJECT_DIR}"
