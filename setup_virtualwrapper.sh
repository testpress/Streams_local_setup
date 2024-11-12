#!/bin/bash

# Update the package list
echo "Running: sudo apt-get update"
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Failed to update package list."
    exit 1
fi

# Install Python development packages
echo "Running: sudo apt-get install -y python3-all-dev"
sudo apt-get install -y python3-all-dev
if [ $? -ne 0 ]; then
    echo "Failed to install python3-all-dev."
    exit 1
fi

# Install virtualenv
echo "Running: sudo apt install -y virtualenv"
sudo apt install -y virtualenv
if [ $? -ne 0 ]; then
    echo "Failed to install virtualenv."
    exit 1
fi

# Install virtualenvwrapper
echo "Running: sudo apt install -y virtualenvwrapper"
sudo apt install -y virtualenvwrapper
if [ $? -ne 0 ]; then
    echo "Failed to install virtualenvwrapper."
    exit 1
fi

# Set up environment variables for virtualenvwrapper
echo "Configuring virtualenvwrapper..."
export WORKON_HOME=~/workspace/
export VIRTUALENVWRAPPER_PYTHON=$(which python3)

# Source virtualenvwrapper.sh to ensure 'workon' is available
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Check if the environment variables are already in .bash_profile
if ! grep -q "export WORKON_HOME=~/workspace/" ~/.bash_profile; then
    echo "Adding configuration to .bash_profile..."
    {
        echo "export WORKON_HOME=~/workspace/"
        echo "export VIRTUALENVWRAPPER_PYTHON=$(which python3)"
        echo "source /usr/local/bin/virtualenvwrapper.sh"
    } >> ~/.bash_profile
else
    echo "Configuration already present in .bash_profile. Skipping..."
fi

# Check if the virtual environment 'streams' already exists
if workon streams 2>/dev/null; then
    echo "Virtual environment 'streams' already exists. Activating it..."
else
    # Create a virtual environment named 'streams' with Python 3
    echo "Creating virtual environment 'streams' with Python 3..."
    mkvirtualenv -p python3 streams
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment 'streams'."
        exit 1
    fi
fi

# Ask user to manually activate the environment
echo "Please manually run the following command to activate the virtual environment:"
echo "1. workon streams"
echo "2. cdvirtualenv"
