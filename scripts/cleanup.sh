#!/bin/bash

# This script cleans up the local network created by scripts/local_network.sh

# Make sure that ansible-avalanche-getting-started has been cloned
if [ ! -d "ansible-avalanche-getting-started" ]; then
  git submodule update --init --recursive
fi

cd ansible-avalanche-getting-started || exit
# Destroy the machines with Terraform + Multipass
terraform -chdir=terraform/multipass destroy -auto-approve
