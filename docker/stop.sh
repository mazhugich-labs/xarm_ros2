#!/usr/bin/env bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

if ! docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
  echo "Container '${CONTAINER_NAME}' does not exist."
  exit 0
fi

docker stop "${CONTAINER_NAME}" >/dev/null
echo "Stopped '${CONTAINER_NAME}'. Run docker/run.sh to start it again."
