#!/bin/bash

# Run Django migrations
echo "Running Django migrations..."
./manage.py migrate
if [ $? -ne 0 ]; then
    echo "Failed to run migrations. Exiting."
    exit 1
fi

# Install Tailwind CSS dependencies (Node.js and npm)
echo "Installing Node.js and npm for Tailwind CSS..."
sudo apt install -y nodejs
sudo apt install -y npm

# Install Tailwind CSS for the Django project
echo "Installing Tailwind CSS..."
./manage.py tailwind install
if [ $? -ne 0 ]; then
    echo "Failed to install Tailwind CSS. Exiting."
    exit 1
fi

# Start Django server without specifying a port (default is 8000)
echo "Starting Django development server in the current tab..."
./manage.py runserver &

# Instructions for running the Tailwind server in the next tab
echo "Django server is running in this tab."
echo "Now, please open a new terminal tab and run the following command to start the Tailwind server:"
echo "./manage.py tailwind start"

# Wait for the user to acknowledge before exiting
echo "Press Enter after you've started the Tailwind server in the next terminal tab..."
read -p "Press Enter to exit..."
