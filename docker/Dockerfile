# Use the official TF-2.6.1  image as the base (This is based on Ubuntu 20.04)
FROM tensorflow/tensorflow:2.6.1-gpu

# Set environment variables
ENV ROS_VERSION noetic
ENV CATKIN_WS /root/agile_autonomy_ws/catkin_aa

RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    python3-pip \
    build-essential \
    wget \
    curl \
    git \
    vim \
    unzip \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install Anaconda
RUN wget -O /tmp/anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh && \
    chmod +x /tmp/anaconda.sh && \
    /tmp/anaconda.sh -b -p /opt/anaconda3 && \
    rm /tmp/anaconda.sh
ENV PATH /opt/anaconda3/bin:$PATH

# Update conda and install required packages
RUN conda update -n base -c defaults conda && \
    conda create --name tf_24 python=3.7.7 && \
#    echo "source activate tf_24" >> /root/.bashrc && \
    /bin/bash -c "source /opt/anaconda3/etc/profile.d/conda.sh && conda activate tf_24 && \
    pip install tensorflow-gpu==2.4 rospkg==1.2.3 pyquaternion open3d opencv-python empy==3.3.4 defusedxml PySide2"

# Building and installing Open3d
RUN apt remove cmake

RUN cd /opt && \
    wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.tar.gz && \
    tar -xvzf cmake-3.20.0-linux-x86_64.tar.gz
RUN ln -s /opt/cmake-3.20.0-linux-x86_64/bin/* /usr/local/bin

RUN cd /root && git clone https://github.com/isl-org/Open3D

RUN apt-get update && apt-get install -y \
    xorg-dev \
    libxcb-shm0 \
    libglu1-mesa-dev \
    python3-dev \
    clang libc++-dev \
    libc++abi-dev \
    libsdl2-dev \
    ninja-build \
    libxi-dev \
    libtbb-dev \
    libosmesa6-dev \
    libudev-dev \
    autoconf \
    libtool

RUN cd /root/Open3D && mkdir build && cd build && cmake .. && make -j$(nproc) && make install    

# Installing ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt update && apt install -y ros-$ROS_VERSION-desktop-full && echo "source /opt/ros/$ROS_VERSION/setup.bash" >> /root/.bashrc

RUN apt-get update && apt-get install -y \
    ros-$ROS_VERSION-octomap-msgs \
    ros-$ROS_VERSION-octomap-ros \
    ros-$ROS_VERSION-joy

RUN apt-get update && apt-get install -y \
    libqglviewer-dev-qt5 \
    libzmqpp-dev \
    libeigen3-dev \
    libglfw3-dev \
    libglm-dev \
    libvulkan1 \
    vulkan-utils \
    gdb \
    python3-empy \
    libsdl-image1.2-dev \
    libsdl-dev

RUN mkdir -p $CATKIN_WS/src

# Add environment variables (Careful! Modify path according to your local setup)
RUN echo "export RPGQ_PARAM_DIR=$CATKIN_WS/src/rpg_flightmare" >> /root/.bashrc

# Might not be necessary for all configs
RUN ln /usr/local/cuda/lib64/libcusolver.so.11 /usr/local/cuda/lib64/libcusolver.so.10

RUN echo "source $CATKIN_WS/devel/setup.bash" >> /root/.bashrc

# Install some python deps
RUN python3 -m pip install rospkg==1.2.3 pyquaternion open3d opencv-python catkin-tools empy==3.3.4 catkin_pkg

# Set workdir
WORKDIR $CATKIN_WS

# Set entrypoint
CMD ["/bin/bash"]

