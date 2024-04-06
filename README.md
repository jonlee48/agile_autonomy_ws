# Agile Autonomy Workspace

Creating a shared catkin workspace, that way we're all on the same dependencies and running the same launch files.

## Installation

Since this workspace already sets up the agile autonomy repo, we only have to run a subset of their installation instructions.

This workspace has been tested with Ubuntu 20.04, Open3D 0.18.0, RTX 4090, GTX 980, cuda 11.2, and cuda 12.2.

### Requirements

The code was tested with Ubuntu 20.04, ROS Noetic, Anaconda v4.8.3., and `gcc/g++` 7.5.0.
Different OS and ROS versions are possible but not supported.

Before you start, make sure that your compiler versions match `gcc/g++` 7.5.0. To do so, use the following commands:

```
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 100
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 100
```

You might need to install `gcc/g++` 7.5.0 first.

```
sudo apt install build-essential
sudo apt -y install gcc-7 g++-7
```

### Step-by-Step Procedure

Use the following commands to create a new catkin workspace and a virtual environment with all the required dependencies.

```bash
cd agile_autonomy_ws
git submodule update --init --recursive

#install extra dependencies (might need more depending on your OS)
sudo apt-get install libqglviewer-dev-qt5 libfmt-dev

# Install external libraries for rpg_flightmare
sudo apt install -y libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev

# Install dependencies for rpg_flightmare renderer
sudo apt install -y libvulkan1 vulkan-utils gdb

# Add environment variables (Careful! Modify path according to your local setup)
echo 'export RPGQ_PARAM_DIR=/home/<path/to/>agile_autonomy_ws/catkin_aa/src/rpg_flightmare' >> ~/.bashrc
```

### Building Open3D from source

I was able 
Follow the instructions [here](https://www.open3d.org/docs/release/compilation.html#ubuntu-macos) to build open3d from source, as there's no apt install for the cpp library.
Open3d requires `cmake --verison` > 3.19. So run the steps [here](https://apt.kitware.com/) before building open3d.

Note the authors test with open3d 0.9.0 ([this tag](https://github.com/isl-org/Open3D/releases/tag/v0.9.0)), but it seems to work fine with version 0.18.0.

Install other dependencies not listed in the original installation guide
```
sudo apt-get install libsdl-image1.2-dev
sudo apt-get install libsdl-dev 
sudo apt-get install ros-noetic-mavros
sudo apt-get install libsdl-dev libsdl-image1.2-dev ros-noetic-octomap ros-noetic-octomap-msgs ros-noetic-octomap-ros
sudo apt-get install ros-noetic-joy
sudo apt install net-tools
```

### Build catkin workspace
Now open a new terminal and type the following commands.

```bash
# Build and re-source the workspace
cd agile_autonomy_ws/catkin_aa
catkin build --cmake-args -DCMAKE_CXX_STANDARD=17 -DPYTHON_EXECUTABLE=/usr/bin/python3
source devel/setup.bash

# Create your learning environment
roscd planner_learning
conda create --name tf_24 python=3.7.7
conda activate tf_24
pip install tensorflow-gpu==2.4
conda install cudnn cudatoolkit
pip install rospkg==1.2.3 pyquaternion open3d opencv-python
# Install other dependencies not listed in the original installation guide
pip install defusedxml PySide2 
```

Now download the flightmare standalone available at [this link](https://zenodo.org/record/5517791/files/standalone.tar?download=1), extract it and put in the `catkin_aa/src/rpg_flightmare/flightrender` folder.

## Running the code

See the README in `catkin_aa/src/agile_autonomy`

## Issues and fixes
- **Issue:** Segmentation fault when running `python train.py --settings_file=config/train_settings.yaml`. Same error as [github issue](https://github.com/uzh-rpg/agile_autonomy/issues/83)
    - Use conda 11.1 in the virtual envrionment (github issue)[https://github.com/uzh-rpg/agile_autonomy/issues/42#issuecomment-1071957916]
- **Issue:** hummingbird/rqt_quad_gui process dies (ValueError: bad marshal data) when running `roslaunch agile_autonomy simulation.launch`.
    - **Fix:** Don't run the launchfile from a conda envrionment `conda deactivate`.
- **Issue:** no kernel image is available for execution on the device 209
    - **Fix:** Add `-gencode=arch=compute_89,code=sm_89` to CMakeLists then catkin clean and rebuild. Replace 89 with the compute capability of your GPU (capability table)[https://developer.nvidia.com/cuda-gpus#compute]. This might require updating cudatoolkit to most recent cuda version supported by `nvidia-smi`. 
        - [github issue 1](https://github.com/uzh-rpg/agile_autonomy/issues/47), [github issue 2](https://github.com/uzh-rpg/agile_autonomy/issues/18)
- **Issue:** catkin build issues with open3d and rviz
    - **Fix:** [github issue](https://github.com/uzh-rpg/agile_autonomy/issues/10#issuecomment-981095386)
- **Issue:** simulator process dying when running `roslaunch agile_autonomy simulation.launch`
    - **Fix:** [github issue](https://github.com/uzh-rpg/agile_autonomy/issues/86)
- **Issue:**
It actually works fine without the conda environments activated
    - **Fix:** `conda deactivate`.
- **Issue:** error `zmq.error.ZQMError Address already in use`
    - **Fix:** [stackoverflow solution](https://stackoverflow.com/questions/19159771/recovering-from-zmq-error-zmqerror-address-already-in-use)
        ```
        sudo netstat -ltnp
        kill -9 <pid>
        ```
- **Issue:** bad callback on running test script
    - **Fix:** [github issue](https://github.com/uzh-rpg/agile_autonomy/issues/88)
