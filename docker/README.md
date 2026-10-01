# Docker workflow

The image is based on Ubuntu 24.04 and ROS 2 Jazzy, matching this repository
branch. It installs package dependencies with `rosdep` and builds the complete
workspace at `/opt/xarm_ws`.

From the repository root:

```bash
docker/build.sh
docker/run.sh
docker/enter.sh
```

The entrypoint automatically sources both ROS 2 and the built workspace. For
example, the README's fake MoveIt demo can be launched from the container shell:

```bash
ros2 launch xarm_moveit_config xarm6_moveit_fake.launch.py
```

Stop the background container without deleting it:

```bash
docker/stop.sh
```

Running `docker/run.sh` again restarts the same stopped container. Override the
defaults with `XARM_ROS2_IMAGE`, `XARM_ROS2_CONTAINER`, or
`XARM_ROS_DOMAIN_ID`. NVIDIA users can request GPU passthrough with, for
example, `XARM_DOCKER_GPU=all docker/run.sh` when the NVIDIA Container Toolkit
is installed. If the image was rebuilt while the container was stopped, the
run script automatically replaces that stale container.

The run script uses host networking so ROS discovery and connections to a
physical robot work normally. It also forwards X11 and `/dev/dri` when
available. If a GUI cannot connect to the display, allow the container's local
root user before starting it:

```bash
xhost +si:localuser:root
```

Revoke that permission after use with `xhost -si:localuser:root`.
