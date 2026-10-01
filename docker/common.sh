#!/usr/bin/env bash

set -euo pipefail

DOCKER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${DOCKER_DIR}/.." && pwd)"

IMAGE_NAME="${XARM_ROS2_IMAGE:-xarm-ros2:jazzy}"
CONTAINER_NAME="${XARM_ROS2_CONTAINER:-xarm-ros2}"
