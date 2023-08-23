#!/bin/bash

# This script bootstraps a local network using ansible-avalanche-getting-started

# Make sure that ansible-avalanche-getting-started has been cloned
if [ ! -d "ansible-avalanche-getting-started" ]; then
  git submodule update --init --recursive
fi

cd ansible-avalanche-getting-started || exit
# Setup ansible-avalanche-getting-started
echo "Setting up ansible-avalanche-getting-started"
./bin/setup.sh
source .venv/bin/activate
ansible-galaxy collection install git+https://github.com/AshAvalanche/ansible-avalanche-collection.git
# Create the machines with Terraform + Multipass
echo "Creating the machines with Terraform + Multipass"
terraform -chdir=terraform/multipass init
terraform -chdir=terraform/multipass apply -auto-approve

# Bootstrap the network with Ansible
echo "Bootstrapping the network with Ansible"
ansible-playbook ash.avalanche.bootstrap_local_network -i inventories/local

# Create the Subnet containing the 2 Subnet-EVM chains
echo "Creating the Subnet"
## Check if a Subnet has already been created
custom_subnets=$(multipass exec validator01 -- ash avalanche subnet list --json | jq 'map(select(.id != "11111111111111111111111111111111LpoYY"))')
if [ "$(echo "$custom_subnets" | jq 'length')" -gt 0 ]; then
  echo "A custom Subnet has already been created. Skipping the creation of the Subnet"
else
  ansible-playbook ash.avalanche.create_subnet -i inventories/local
fi

TERRAFORM_DIR=terraform/multipass source ../scripts/env_vars.sh

# Update config files with the new Subnet ID and blockchain ID
sed -e "s/avalanchego_track_subnets: \[.*\]/avalanchego_track_subnets: [$WARP_SUBNET_ID]/" inventories/local/group_vars/avalanche_nodes.yml -i
sed -e "s/avalanchego_chains_configs: { \".*\"/avalanchego_chains_configs: { \"$HOLYTERRA_CHAIN_ID\"/" inventories/local/group_vars/avalanche_nodes.yml -i

# Add the Subnet to the list of tracked Subnets
echo "Adding the Subnet to the list of tracked Subnets"
ansible-playbook ash.avalanche.provision_nodes -i inventories/local

cd - || exit

# Template the Ash CLI config file
echo "Templating the Ash CLI config file"
mkdir -p ash-conf
cat ansible-avalanche-getting-started/terraform/multipass/local-test-network.yml >ash-conf/local.yml
envsubst <scripts/warp-conf.txt >>ash-conf/local.yml
