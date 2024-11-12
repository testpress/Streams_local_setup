
# Streams Local Setup

This guide helps you set up the Streams project locally. Follow the steps below.

## Prerequisites
- Ensure you have Git installed.
- Ensure you have virtualenvwrapper installed for virtual environment management.

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone git@github.com:testpress/Streams_local_setup.git
   ```
2. **Navigate to the Project Directory**
   ```bash
   cd Streams_local_setup
   ```

3. **Set File Permissions**
   Grant execute permissions to the necessary setup scripts:
   ```bash
   chmod +x run_server.sh setup_streams.sh setup_virtualwrapper.sh
   ```

4. **Run the Virtual Environment Setup Script**
   Run the `setup_virtualwrapper.sh` script to set up the virtual environment.
   ```bash
   ./setup_virtualwrapper.sh
   ```

5. **Activate the Virtual Environment Manually**
   After running the setup script, activate the virtual environment:
   ```bash
   workon streams
   cdvirtualenv
   ```

6. **Move and Run the Streams Setup Script**
   Move the `setup_streams.sh` script to the current directory and run it:
   ```bash
   mv setup_streams.sh ./
   ./setup_streams.sh
   ```

7. **Navigate to the Streams Directory**
   ```bash
   cd streams
   ```

8. **Create and Configure Environment Variables**
   In the `streams` directory, create a `.env` file and add the required environment variables.

9. **Move and Run the Server Script**
   Move `run_server.sh` to the `streams` directory and start the server:
   ```bash
   mv ../run_server.sh ./
   ./run_server.sh
   ```

## Additional Notes
- Ensure all environment variables in `.env` are correctly configured to avoid setup issues.
- The server should start after completing these steps.

Happy coding!
```