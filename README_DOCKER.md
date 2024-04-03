# Agile Autonomy Workspace (Docker Setup)

## Install Docker
Install Docker on your local host machine. For installation instructions, refer to [Docker Documentation](https://docs.docker.com/install/). For GPU support on Linux, also install NVIDIA Docker by following the instructions provided [here](https://github.com/NVIDIA/nvidia-docker).

## Setting up the repository
```shell
git clone https://github.com/jonlee48/agile_autonomy_ws.git
cd agile_autonomy_ws
git submodule update --init --recursive
```
Download the Flightmare standalone package from [this link](https://zenodo.org/record/5517791/files/standalone.tar?download=1), extract it, and place it in the `agile_autonomy_ws/catkin_aa/src/rpg_flightmare/flightrender` folder.

### Building the Docker image
```shell
cd docker
docker build -t agile_autonomy_docker .
```

### Launching the container
In the `launch_container.sh` file, modify the path to `catkin_aa` to match the path on your host machine:
```shell
--volume=<path-to-catkin_aa>:/root/agile_autonomy_ws/catkin_aa \
```
Then execute the following commands:
```shell
xhost +
bash launch_container.sh
```

### Configuring the Catkin workspace
Run the following commands within the Docker container:

```shell
export ROS_VERSION=noetic
catkin init
catkin config --extend /opt/ros/$ROS_VERSION
catkin config --merge-devel
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fdiagnostics-color
```

### Building the workspace
```shell
catkin build --cmake-args -DCMAKE_CXX_STANDARD=17
```

If you encounter an error during the compilation of `numpy_eigen`, make the following change and rebuild:
In `agile_autonomy_ws/catkin_aa/src/numpy_eigen/src/autogen_module/numpy_eigen_export_module.cpp`, line 258:
Change `import_array();` to `_import_array();`


### Testing installation
Run this in docker
```shell
roslaunch agile_autonomy simulation.launch
```
To attach a new shell to the Docker container, use the following command:
```shell
docker exec -it agile_autonomy_container bash
```
Then run the following commands in the new shell:
```shell
source activate tf_24
python test_trajectories.py --settings_file=config/test_settings.yaml
```

If you encounter an error stating "no kernel image is available for execution on the device 209", update `CUDA_NVCC_FLAGS` with the appropriate [gencode](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/) for your GPU in `agile_autonomy_ws/catkin_aa/src/agile_autonomy/data_generation/agile_autonomy/CMakeLists.txt`. For RTX 4090, use:
```shell
-gencode=arch=compute_89,code=sm_89
```
For RTX 3060, use:
```shell
-gencode=arch=compute_86,code=sm_86
```
