#!/bin/bash

# Set up the repository URL and target directory
REPO_URL="git@github.com:testpress/streams.git"
TARGET_DIR="streams"

# Check if manage.py exists in the current directory
if [ -f "manage.py" ]; then
    echo "manage.py found in the current directory. Skipping repository clone..."
else
    # If the 'streams' directory exists, remove it to re-clone
    if [ -d "$TARGET_DIR" ]; then
        echo "'$TARGET_DIR' directory exists. Skipping repository clone..."
    else
        # Clone the repository
        echo "Cloning repository: $REPO_URL"
        git clone $REPO_URL
        if [ $? -ne 0 ]; then
            echo "Failed to clone the repository."
            exit 1
        fi
    fi
fi

# Check if we are in the correct directory already or need to move
echo "Current directory: $(pwd)"

# Check if the 'streams' directory exists in the current location
if [ -d "$TARGET_DIR" ]; then
    echo "Navigating into $TARGET_DIR..."
    cd "$TARGET_DIR" || { echo "Failed to navigate to $TARGET_DIR."; exit 1; }
else
    echo "'$TARGET_DIR' directory doesn't exist after cloning. Exiting."
    exit 1
fi

# Install required dependencies
echo "Installing dependencies from requirements/local.txt"
pip install -r requirements/local.txt
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies."
    exit 1
fi

# Check if PostgreSQL repository is already added
if ! grep -q "deb http://apt.postgresql.org/pub/repos/apt" /etc/apt/sources.list.d/pgdg.list; then
    echo "Adding PostgreSQL repository..."
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
else
    echo "PostgreSQL repository already added, skipping..."
fi

# Install PostgreSQL if not already installed
if ! dpkg -l | grep -q postgresql-15; then
    echo "Installing PostgreSQL 15..."
    sudo apt-get -y install postgresql-15
else
    echo "PostgreSQL 15 is already installed, skipping..."
fi

# Add Citus repository for package manager
echo "Adding Citus repository..."
curl https://install.citusdata.com/community/deb.sh | sudo bash

# Install the Citus PostgreSQL extension
echo "Installing PostgreSQL 15 Citus extension..."
sudo apt-get -y install postgresql-15-citus-11.1

# Configure PostgreSQL to allow localhost access with trust authentication
echo "Configuring PostgreSQL pg_hba.conf for localhost access..."
sudo sed -i '/# IPv4 local connections:/a\host    all             all             127.0.0.1/32            trust' /etc/postgresql/15/main/pg_hba.conf
sudo sed -i '/# IPv6 local connections:/a\host    all             all             ::1/128                 trust' /etc/postgresql/15/main/pg_hba.conf

# Reload PostgreSQL service to apply the changes
echo "Reloading PostgreSQL service..."
sudo systemctl reload postgresql

# Check if PostgreSQL user 'testpress' already exists
USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='testpress'")

if [ "$USER_EXISTS" != "1" ]; then
    # Create the testpress user and set password from .env file
    if [ -f ".env" ]; then
        # Load password from .env file
        TESTPRESS_PASSWORD=$(grep -oP '(?<=^TESTPRESS_PASSWORD=).*' .env)

        if [ -z "$TESTPRESS_PASSWORD" ]; then
            echo "TESTPRESS_PASSWORD is not set in the .env file. Exiting."
            exit 1
        fi

        echo "Creating PostgreSQL user 'testpress'..."
        sudo -u postgres createuser testpress -sW
        echo "Setting password for user 'testpress'..."
        sudo -u postgres psql -c "ALTER USER testpress WITH PASSWORD '$TESTPRESS_PASSWORD';"
    else
        echo ".env file not found. Exiting."
        exit 1
    fi
else
    echo "PostgreSQL user 'testpress' already exists. Skipping user creation."
fi

# Check if the 'streams' database exists
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='streams'")

if [ "$DB_EXISTS" != "1" ]; then
    # Create the 'streams' database and assign the 'testpress' user as the owner
    echo "Creating PostgreSQL database 'streams'..."
    sudo -u postgres createdb streams -O testpress
else
    echo "Database 'streams' already exists. Skipping database creation."
fi

# Load the Citus extension into the 'streams' database, only if not already installed
EXTENSION_EXISTS=$(sudo -u postgres psql streams -tAc "SELECT 1 FROM pg_extension WHERE extname='citus'")

if [ "$EXTENSION_EXISTS" != "1" ]; then
    echo "Loading Citus extension into 'streams' database..."
    sudo -u postgres psql streams -c "CREATE EXTENSION citus;"
else
    echo "Citus extension already loaded in 'streams'. Skipping extension loading."
fi

# Verify the Citus extension installation
echo "Verifying Citus extension installation..."
sudo -u postgres psql streams -c "SELECT * FROM citus_version();"

# Final prompt to navigate to the 'streams' directory
echo "Setup completed successfully!"
echo "Please type 'cd streams' to navigate to the 'streams' directory."
