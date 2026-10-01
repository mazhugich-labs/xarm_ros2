#!/usr/bin/env bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

if docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
  if [[ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}")" == "true" ]]; then
    echo "Container '${CONTAINER_NAME}' is already running. Use docker/enter.sh to open a shell."
    exit 0
  fi

  container_image="$(docker inspect --format '{{.Image}}' "${CONTAINER_NAME}")"
  requested_image="$(docker image inspect --format '{{.Id}}' "${IMAGE_NAME}" 2>/dev/null || true)"
  if [[ -n "${requested_image}" && "${container_image}" != "${requested_image}" ]]; then
    docker rm "${CONTAINER_NAME}" >/dev/null
    echo "Removed stopped container because '${IMAGE_NAME}' was rebuilt."
  else
    docker start "${CONTAINER_NAME}" >/dev/null
    echo "Started existing container '${CONTAINER_NAME}'."
    exit 0
  fi
fi

docker_args=(
  run
  --detach
  --init
  --name "${CONTAINER_NAME}"
  --network host
  --ipc host
  --env "DISPLAY=${DISPLAY:-}"
  --env "QT_X11_NO_MITSHM=1"
  --volume /tmp/.X11-unix:/tmp/.X11-unix:rw
)

if [[ -n "${XAUTHORITY:-}" && -f "${XAUTHORITY}" ]]; then
  docker_args+=(
    --env XAUTHORITY=/tmp/.docker.xauth
    --volume "${XAUTHORITY}:/tmp/.docker.xauth:ro"
  )
elif [[ -f "${HOME}/.Xauthority" ]]; then
  docker_args+=(
    --env XAUTHORITY=/tmp/.docker.xauth
    --volume "${HOME}/.Xauthority:/tmp/.docker.xauth:ro"
  )
fi

if [[ -e /dev/dri ]]; then
  docker_args+=(--device /dev/dri:/dev/dri)
fi

if [[ -n "${XARM_ROS_DOMAIN_ID:-}" ]]; then
  docker_args+=(--env "ROS_DOMAIN_ID=${XARM_ROS_DOMAIN_ID}")
fi

if [[ -n "${XARM_DOCKER_GPU:-}" ]]; then
  docker_args+=(--gpus "${XARM_DOCKER_GPU}")
fi

docker_args+=("${IMAGE_NAME}")
docker "${docker_args[@]}" "$@" >/dev/null

echo "Started '${CONTAINER_NAME}' from '${IMAGE_NAME}'."
echo "Enter it with: docker/enter.sh"
