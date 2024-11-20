#!/bin/bash

# ANSI color codes
BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
ORANGE="\033[1;33m"
RESET="\033[0m"

# Directory and Repository Variables
DIR_STABLE=~/luna_workspace_stable
#DIR_DEV=~/tric_robotics/luna_workspace_dev
REPO_STABLE_URL=https://github.com/tricrobotics/luna_v0_ws.git

# Functions to echo messages in different colors
echo_blue() {
    echo -e "${BLUE}$1${RESET}"
}

echo_green() {
    echo -e "${GREEN}$1${RESET}"
}
	
echo_red() {
    echo -e "${RED}$1${RESET}"
}
    
echo_orange() {
    echo -e "${ORANGE}$1${RESET}"
}

# Function to download and install a .deb package
install_deb() {
    wget -N "$1" -O temp_package.deb
    if sudo apt install ./temp_package.deb -y; then
        installStatus["$2"]="success"
    else
        installStatus["$2"]="fail"
    fi
    rm temp_package.deb
}

# Initialize an array to keep track of installation status
declare -A installStatus
declare -A rosStatus

# Beginning border and message
echo_blue "**************************************************"
echo_blue "********** Executing Test Robot Setup ************"
echo_blue "**************************************************"

# Updating package lists
echo_orange "Updating package lists..."
sudo apt update -y && installStatus["Update package lists"]="success"

# Installing Vim
echo_orange "Installing Vim..."
if sudo apt install vim -y; then
    installStatus["Vim"]="success"
else
    installStatus["Vim"]="fail"
fi

# Installing Visual Studio Code
echo_orange "Installing Visual Studio Code..."
install_deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" "Visual Studio Code"

# Installing Git
echo_orange "Installing Git..."
if sudo apt install git -y; then
    installStatus["Git"]="success"
else
    installStatus["Git"]="fail"
fi

# Installing Google Chrome (adding Google repository to allow updates)
echo_orange "Installing Google Chrome..."
if wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &&
   sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' &&
   sudo apt update && sudo apt install google-chrome-stable -y; then
    installStatus["Google Chrome"]="success"
else
    installStatus["Google Chrome"]="fail"
fi

# Enabling OpenSSH
echo_orange "Enabling OpenSSH..."
if sudo apt install openssh-server -y && sudo systemctl enable ssh && sudo systemctl start ssh; then
    installStatus["OpenSSH"]="success"
else
    installStatus["OpenSSH"]="fail"
fi

# Installing AnyDesk
echo_orange "Installing AnyDesk..."
install_deb "https://download.anydesk.com/linux/anydesk_6.2.1-1_amd64.deb" "AnyDesk"

echo_orange "Starting ROS Noetic Installation Sequence..."
echo_blue "Adding ROS Noetic to sources.list..."
if sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'; then
    rosStatus["ROS Noetic added to sources.list"]="success"
else
    rosStatus["ROS Noetic added to sources.list"]="fail"
fi    

echo_blue "Setting up keys..."
if sudo apt install curl -y && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -; then
    rosStatus["Key setup"]="success"
else
    rosStatus["Key setup"]="fail"
fi    

echo_blue "Updating package lists after adding ROS Noetic repository..."
if sudo apt update -y; then
    rosStatus["Package lists updated"]="success"
else
    rosStatus["Package lists updated"]="fail"
fi    

echo_blue "Installing ROS Noetic: Desktop-Full"
if sudo apt install ros-noetic-desktop-full -y; then
    rosStatus["ROS Noetic Installation"]="success"
else
    rosStatus["ROS Noetic Installation"]="fail"
fi    

echo_blue "Initializing rosdep..."
if sudo rosdep init && rosdep update; then
    rosStatus["rosdep initialized and updated"]="success"
else
    rosStatus["rosdep initialized and updated"]="fail"
fi

echo_blue "Sourcing ~/.bashrc..."
if echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc && source ~/.bashrc; then
    rosStatus["Sourced ~/.bashrc"]="success"
else
    rosStatus["Sourced ~/.bashrc"]="fail"
fi

echo_blue "Installing dependencies for building ROS packages..."
if sudo apt install python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y; then
    rosStatus["Dependency installation"]="success"
else
    rosStatus["Dependency installation"]="fail"
fi

# Summary border and message
echo_blue "**************************************************"
echo_blue "********** ROS Installation Summary **************"
echo_blue "**************************************************"

rosInstallationSuccessful=1

for key in "${!rosStatus[@]}"; do
    if [ ${rosStatus[$key]} = "success" ]; then
        echo -e "${key}: ${GREEN}Success${RESET}"
    else
	rosInstallationSuccessful=0
        echo -e "${key}: ${RED}Fail${RESET}"
    fi
done

if [ $rosInstallationSuccessful -eq 1 ]; then
    echo_green "ROS Noetic Installation Successful"
    installStatus["ROS Noetic Desktop Installation"]="success"
    
else
    echo_red "Error(s) with ROS Noetic Installation"
    installStatus["ROS Noetic Desktop Installation"]="fail"
fi

# Summary border and message
echo_blue "**************************************************"
echo_blue "******** Software Installation Summary ***********"
echo_blue "**************************************************"

# Loop through the installation status array
for key in "${!installStatus[@]}"; do
    if [ ${installStatus[$key]} = "success" ]; then
        echo -e "${key}: ${GREEN}Installed successfully${RESET}"
    else
        echo -e "${key}: ${RED}Installation failed${RESET}"
    fi
done

echo_orange "Creating directories..."
cd
 
mkdir projects
cd projects &&  mkdir rs_camera_test && cd

mkdir luna_workspace_stable
cd

# Cloning stable luna workspace to local directory
cd "$DIR_STABLE"
echo "Cloning stable luna workspace to local directory..."
git clone jbd-tric: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@$REPO_STABLE_URL

echo "Repository cloned successfully."
cd

# SDK 2.0 installation reference: https://dev.intelrealsense.com/docs/compiling-librealsense-for-linux-ubuntu-guide

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Installing dependencies for Intel RealSense SDK 2.0...${NC}"
sleep 3

cd 

# updating package manager
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

# installing core dependencies for librealsense
sudo apt-get install libssl-dev libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev

# installing cmake build tools
sudo apt-get install git wget cmake build-essential

# prompt the user to confirm camera is disconnected from the device
echo "*** PLEASE ENSURE CAMERA IS DISCONNECTED FROM THIS DEVICE PRIOR TO PROCEEDING WITH NEXT STEPS ***"
read -p " Press <ENTER> when ready..."

# preparing Linux backend and .dev environment
sudo apt-get install libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev at
sudo apt-get install libudev-dev

# cloning realsense repo
git clone https://github.com/IntelRealSense/librealsense.git
./scripts/setup_udev_rules.sh

# build and apply patched kernel modules
./scripts/patch-realsense-ubuntu-lts-hwe.sh
sudo dmesg | tail -n 50

echo -g "Ready to build librealsense2 sdk"
cd ~/librealsense && mkdir build && cd build

# run cmake configuration
cmake ../ -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=true

# recompile and install librealsense2 binaries
sudo make uninstall && make clean && make && sudo make install

# installing python bindings
sudo apt-get install python3-dev python3-setuptools
cmake .. -DBUILD_PYTHON_BINDINGS=bool:true

# installing pip, just in case
sudo apt install pip -y

# installing pyrealsense2 wrapper
pip install pyrealsense2

echo -e "${GREEN} Ready to use Intel RealSense SDK 2.0!${NC}"

# End border and message
echo_blue "**************************************************"
echo_blue "*********** Test Robot Setup Complete ************"
echo_blue "**************************************************"
