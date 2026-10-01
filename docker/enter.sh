#!/usr/bin/env bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

if [[ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null || true)" != "true" ]]; then
  echo "Container '${CONTAINER_NAME}' is not running. Start it with docker/run.sh." >&2
  exit 1
fi

if (( $# == 0 )); then
  set -- bash
fi

exec_args=(exec)
if [[ -t 0 && -t 1 ]]; then
  exec_args+=(-it)
fi

docker "${exec_args[@]}" "${CONTAINER_NAME}" /ros_entrypoint.sh "$@"
