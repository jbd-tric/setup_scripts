#!/bin/bash

# ANSI color codes
BLUE="\033[1;34m"
GREEN="\033[1;32m"
RED="\033[1;31m"
ORANGE="\O33[1;33m"
RESET="\033[0m"

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
echo_blue "********** Executing Workstation Setup **********"
echo_blue "**************************************************"

# Updating package lists
echo_orange "Updating package lists..."
sudo apt update -y && installStatus["Update package lists"]="success"

# Installing Google Chrome
echo_orange "Installing Google Chrome..."
install_deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "Google Chrome"

# Installing Slack
echo_orange "Install Slack Desktop Application..."
if sudo snap install slack --classic; then
    installStatus["Slack"]="success"
else
    installStatus["Slack"]="fail"
fi

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

# Installing PyCharm Professional via snap
echo_orange "Installing PyCharm Professional..."
if sudo snap install pycharm-professional --classic; then
    installStatus["PyCharm Professional"]="success"
else
    installStatus["PyCharm Professional"]="fail"
fi

# Installing Git
echo_orange "Installing Git..."
if sudo apt install git -y; then
    installStatus["Git"]="success"
else
    installStatus["Git"]="fail"
fi

# Initializing Git Credentials


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

if rosInstallationSuccessful=1; then
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
mkdir tric_robotics
cd tric_robotics
mkdir repositories
cd 

# End border and message
echo_blue "**************************************************"
echo_blue "********** Workstation Setup Complete ***********"
echo_blue "**************************************************"

