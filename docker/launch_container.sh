#!/bin/sh
RPG_HOST_DIR=$1
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
sudo touch $XAUTH
sudo xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Comment out if you don't have a nvidia GPU
# More info: http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration
GPU_OPTIONS="--gpus all"

docker run --privileged --rm -it \
           --volume=$XSOCK:$XSOCK:rw \
           --volume=$XAUTH:$XAUTH:rw \
           --volume=/dev:/dev:rw \
           --volume=/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
           --volume=<path-to-catkin_aa>:/root/agile_autonomy_ws/catkin_aa \
           ${GPU_OPTIONS} \
           --env="XAUTHORITY=${XAUTH}" \
           --env="DISPLAY=${DISPLAY}" \
           --env=TERM=xterm-256color \
           --env=QT_X11_NO_MITSHM=1 \
           --name agile_autonomy_container \
           agile_autonomy_docker \
           bash
