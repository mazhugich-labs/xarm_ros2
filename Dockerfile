# syntax=docker/dockerfile:1

ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-base-noble

ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=${ROS_DISTRO} \
    WORKSPACE=/opt/xarm_ws \
    QT_X11_NO_MITSHM=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        mesa-utils \
        python3-colcon-common-extensions \
        python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${WORKSPACE}
COPY . src/xarm_ros2

# Install dependencies declared by all packages, including MoveIt, RViz and
# Gazebo Harmonic, and then build the complete workspace from source.
RUN rosdep update \
    && apt-get update \
    && rosdep install \
        --from-paths src \
        --ignore-src \
        --rosdistro "${ROS_DISTRO}" \
        --as-root apt:false \
        --default-yes \
    && rm -rf /var/lib/apt/lists/* \
    && source "/opt/ros/${ROS_DISTRO}/setup.bash" \
    && colcon build --event-handlers console_direct+

COPY docker/entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["sleep", "infinity"]
