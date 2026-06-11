#!/bin/bash
# Auto-setup script for a new Linux instance

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing essential tools..."
sudo apt install git curl wget build-essential -y

echo "Setup complete!"
