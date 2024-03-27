# Agile Autonomy Workspace

Creating a shared catkin workspace, that way we're all on the same dependencies and running the same launch files.

## Installation

Since this workspace already sets up the agile autonomy repo, we only have to run a subset of their installation instructions.

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
sudo apt-get install libqglviewer-dev-qt5

# Install external libraries for rpg_flightmare
sudo apt install -y libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev

# Install dependencies for rpg_flightmare renderer
sudo apt install -y libvulkan1 vulkan-utils gdb

# Add environment variables (Careful! Modify path according to your local setup)
echo 'export RPGQ_PARAM_DIR=/home/<path/to/>agile_autonomy_ws/catkin_aa/src/rpg_flightmare' >> ~/.bashrc
```

### Installing Open3D

Tested with open3d 0.9.0.0
The `open3d_conversions` package requires open3d. I had to install open3d from source, as there's no apt install for the cpp library. 

First, you need a `cmake --verison` > 3.19. So run the 6 steps [here](https://apt.kitware.com/).

Then follow these steps to build open3d from source [here](https://www.open3d.org/docs/release/compilation.html#ubuntu-macos). 

I kept on getting the build error `#include<Open3D/Open3D.h>` no such file or directory . It turned out my Open3D package was installed in `/usr/local/include/` as `open3d/Open3D.h` not `Open3D/Open3D.h`. Similar build errors with open3d were fixed by correcting the path to the header files to match those in `/usr/local/include/`.

### Other prereqs

```
sudo apt-get install libsdl-image1.2-dev
sudo apt-get install libsdl-dev 
sudo apt-get install ros-${ROS_DISTRO}-mavros
```

### Build workpsace
Now open a new terminal and type the following commands.

```bash
# Build and re-source the workspace
cd agile_autonomy_ws/catkin_aa
catkin build --cmake-args -DCMAKE_CXX_STANDARD=17
source devel/setup.bash

# Create your learning environment
roscd planner_learning
conda create --name tf_24 python=3.7
conda activate tf_24
pip install tensorflow-gpu==2.4
pip install rospkg==1.2.3 pyquaternion open3d opencv-python
pip install defusedxml PySide2 # other missing dependencies
```

Now download the flightmare standalone available at [this link](https://zenodo.org/record/5517791/files/standalone.tar?download=1), extract it and put in the `catkin_aa/src/rpg_flightmare/flightrender` folder.


## Issues and fixes
- **Issue:** build issues with open3d and rviz
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
