FROM ros:foxy-ros-base

WORKDIR /opt/rmf

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install websocket websockets websocket-client requests

# Clone the repository
WORKDIR /opt/rmf/src
RUN echo 'Checking out GIT version of repo:' main && \
    git clone https://github.com/open-rmf/rmf_internal_msgs.git && \
    git clone https://github.com/sharp-rmf/kone-ros-api.git && \
    cd kone-ros-api && \
    git checkout main

# Verify the contents
RUN ls -la /opt/rmf/src/kone-ros-api

# Setup the workspace
WORKDIR /opt/rmf
RUN . /opt/ros/foxy/setup.sh && apt-get update && rosdep update
RUN . /opt/ros/foxy/setup.sh && rosdep install -y --from-paths /opt/rmf/src/kone-ros-api --ignore-src

# Build the workspace
RUN . /opt/ros/foxy/setup.sh && colcon build --packages-select kone_ros_api && colcon build --packages-select rmf_lift_msgs

# Ensure the entrypoint script sources the ROS setup
RUN echo 'source /opt/rmf/install/setup.bash' >> /ros_entrypoint.sh
RUN sed -i '$iros2 run kone_ros_api koneNode_v2' /ros_entrypoint.sh

# Ensure proper permissions for entrypoint
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

