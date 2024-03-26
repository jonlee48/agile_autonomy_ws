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
vcs-import < agile_autonomy/dependencies.yaml
# cd rpg_mpl_ros
git submodule update --init --recursive

#install extra dependencies (might need more depending on your OS)
sudo apt-get install libqglviewer-dev-qt5

# Install external libraries for rpg_flightmare
sudo apt install -y libzmqpp-dev libeigen3-dev libglfw3-dev libglm-dev

# Install dependencies for rpg_flightmare renderer
sudo apt install -y libvulkan1 vulkan-utils gdb

# Add environment variables (Careful! Modify path according to your local setup)
echo 'export RPGQ_PARAM_DIR=/home/<path/to/>catkin_aa/src/rpg_flightmare' >> ~/.bashrc
```

### Installing Open3D

The `open3d_conversions` package requires open3d. I had to install open3d from source, as there's no apt install for the cpp library. 

First, you need a `cmake --verison` > 3.19. So run the 6 steps [here](https://apt.kitware.com/).

Then follow these steps to build open3d from source [here](https://www.open3d.org/docs/release/compilation.html#ubuntu-macos). 

I kept on getting the build error `#include<Open3D/Open3D.h>` no such file or directory . It turned out my Open3D package was installed in `/usr/local/include/` as `open3d/Open3D.h` not `Open3D/Open3D.h`.
So I just changed the include to `#include<open3d/Open3D.h>` in `src/rpg_mpl_ros/open3d_conversions/include/open3d_conversions/open3d_conversions.h`.

I also had to change line 9 and 10 in `src/rpg_mpl_ros/mpl_external_planner/include/mpl_external_planner/ellipsoid_planner/ellipsoid_util.h` to be lowercase.
```
#include <open3d/geometry/KDTreeFlann.h>
#include <open3d/geometry/PointCloud.h>
```

And lines 5-7 in `src/agile_autonomy/data_generation/traj_sampler/include/traj_sampler/kdtree.h`
```
#include <open3d/geometry/KDTreeFlann.h>
#include <open3d/geometry/PointCloud.h>
#include <open3d/io/PointCloudIO.h>
```

### Other prereqs

```
sudo apt-get install libsdl-image1.2-dev
sudo apt-get install libsdl-dev 
```

### rotors_gazebo_plugin

Issue is std::options is used but is only available in c++17 not c++11 which is the standard that is specified in the CMakeLists.txt.

```
cd src/rotors_simulator/rotors_gazebo_plugins
# change CMakeLists.txt line 94 to use c++17
```

### planning_ros_utils
An error occurs while compiling the package planning_ros_utils. A workaround to get it compiling is to comment out line 39 in `src/rpg_mpl_ros/planning_ros_utils/src/planning_rviz_plugins/map_display.cpp`. See [this](https://github.com/uzh-rpg/rpg_mpl_ros/issues/1) issue.

```
//update_nh_.setCallbackQueue(point_cloud_common_->getCallbackQueue());
```

One line has to be commented out, according to this [issue](https://github.com/uzh-rpg/rpg_mpl_ros/issues/1)

### packages in rpg_mpl_ros (mpl_test_node, mpl_test_node, open3d_conversions)
Also the CMakeLists in `rpg_mpl_ros/mpl_external_planner needs to be c++17. Change line 3 from c++11 to c++17.

And same for the two instances of `11` in `rpg_mpl_ros/mpl_test_node` line 7.

Actually, `mpl_test_node` needs to be compiled with
```
catkin build mpl_test_node -DCMAKE_CXX_STANDARD=17
```

So to compile all 71 packages do
```
catkin build -DCMAKE_CXX_STANDARD=17
```


Added two lines to `rpg_mpl_ros/open3d_conversions/CMakeLists.txt` after line 1.
```
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
```

### Build workpsace
Now open a new terminal and type the following commands.

```bash
# Build and re-source the workspace
cd agile_autonomy_ws/catkin_aa
catkin build
#. ../devel/setup.bash
source devel/setup.bash

# Create your learning environment
roscd planner_learning
conda create --name tf_24 python=3.7
conda activate tf_24
pip install tensorflow-gpu==2.4
pip install rospkg==1.2.3 pyquaternion open3d opencv-python
pip install defusedxml PySide2 # other missing dependencies
```

Now download the flightmare standalone available at [this link](https://zenodo.org/record/5517791/files/standalone.tar?download=1), extract it and put in the [flightrender](https://github.com/antonilo/flightmare_agile_autonomy/tree/main/flightrender) folder.


## Issues

There's an issue with the simulator dying ([issue](https://github.com/uzh-rpg/agile_autonomy/issues/86))
```
roslaunch agile_autonomy simulation.launch
```

It actually works fine without the conda environments activated
`conda deactivate`.

Also if getting an error "zmq.error.ZQMError Address already in use" do this. From this [stackoverflow](https://stackoverflow.com/questions/19159771/recovering-from-zmq-error-zmqerror-address-already-in-use)
1. `sudo netstat -ltnp`
2. `kill -9 <pid>`
