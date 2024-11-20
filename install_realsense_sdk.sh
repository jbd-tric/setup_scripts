#!/bin/bash

# Script to install Intel RealSense SDK 2.55.1
# SDK 2.55.1 installation reference: https://dev.intelrealsense.com/docs/compiling-librealsense-for-linux-ubuntu-guide

GREEN='\033[0;32m'
NC='\033[0m'

# Exit the script immediately if an error is encountered
set -e
echo -e "${GREEN}Installing dependencies for Intel RealSense SDK 2.55.1...${NC}"
echo -e "${GREEN}NOTE: This process may take up to 20-30 minutes${NC}"
# prompt the user to confirm camera is disconnected from the device
echo -e "${GREEN}*** PLEASE ENSURE CAMERA IS DISCONNECTED FROM THIS DEVICE PRIOR TO STARTING INSTALLATION ***${NC}"
read -p "${GREEN} Press <ENTER> when ready...${NC}"
sleep 3

cd "$HOME"

# updating package manager
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

# installing core dependencies for librealsense
sudo apt-get install libssl-dev libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev

# installing cmake build tools
sudo apt-get install git wget cmake build-essential

# preparing Linux backend and .dev environment
sudo apt-get install libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev at

# Clone the librealsense repository
echo -e "${GREEN}Cloning librealsense repository...${NC}"
cd "$HOME"
git clone https://github.com/IntelRealSense/librealsense.git
cd librealsense
git checkout v2.55.1

# appy udev rules
./scripts/setup_udev_rules.sh

# build and apply patched kernel modules
./scripts/patch-realsense-ubuntu-lts-hwe.sh
sudo dmesg | tail -n 50

echo -e "${GREEN}Ready to build librealsense2 SDK v2.55.1${NC}"
cd ~/librealsense && mkdir build && cd build

# run cmake configuration
cmake ../ -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=true

# recompile and install librealsense2 binaries
sudo make uninstall && make clean && make -j$(nproc) && sudo make install

# installing python bindings
sudo apt-get install -y python3-dev python3-setuptools
cmake .. -DBUILD_PYTHON_BINDINGS=bool:true
make -j$(nproc)
sudo make install

# installing pip, just in case
sudo apt-get install -y python3-pip
python3 -m pip install --upgrade pip

# installing pyrealsense2 wrapper
echo -e "${GREEN}Installing the pyrealsense2 wrapper...${NC}"
python3 -m pip install pyrealsense2

echo -e "${GREEN} Ready to use Intel RealSense SDK 2.55.1!${NC}"
echo "Plug in RealSense camera and run 'realsense-viewer' to launch camera and upgrade firmware"
