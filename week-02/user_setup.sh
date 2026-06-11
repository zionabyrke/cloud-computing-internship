#!/bin/bash
# User creation script
# Usage: bash user_setup.sh <username>
# Example: bash user_setup.sh intern2

USERNAME=$1

if [[ -z "$USERNAME" ]]; then
  echo "Usage: bash user_setup.sh <username>"
  exit 1
fi

sudo adduser $USERNAME
sudo usermod -aG sudo $USERNAME
echo "User $USERNAME created and added to sudo group."
