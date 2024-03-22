#!/bin/bash

# Description: This script installs and sets up Devika, a powerful AI assistant.
# Author: Flames Co. LTD
# Date: 2023-05-22

set -e  # Exit immediately if any command fails

# Function to display error messages and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error_exit "This script must be run as root. Please use 'sudo' or run as the root user."
fi

# Install uv and bun
echo "Installing uv and bun..."
curl -sSL https://github.com/astral-sh/uv/raw/main/install.sh | bash || error_exit "Failed to install uv."
bun install bun || error_exit "Failed to install bun."

# Clone the Devika repository
echo "Cloning Devika repository..."
git clone https://github.com/stitionai/devika.git || error_exit "Failed to clone Devika repository."
cd devika/

# Setup Python virtual environment and install dependencies
echo "Setting up Python virtual environment and installing dependencies..."
uv venv || error_exit "Failed to create Python virtual environment."
source .uv/bin/activate || error_exit "Failed to activate Python virtual environment."
uv pip install -r requirements.txt || error_exit "Failed to install Python dependencies."

# Setup UI
echo "Setting up UI..."
cd ui/
bun install || error_exit "Failed to install UI dependencies."
bun run dev &
UI_PID=$!

# Start Devika
echo "Starting Devika..."
cd ..
python3 devika.py &
DEVIKA_PID=$!

# Wait for Devika and UI processes to finish
wait $DEVIKA_PID
wait $UI_PID

echo "Devika setup and execution completed successfully."
