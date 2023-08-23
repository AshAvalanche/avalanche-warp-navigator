#!/bin/bash

# This script deploys a block explorer using ansible-avalanche-getting-started

# Make sure that ansible-avalanche-getting-started has been cloned
if [ ! -d "ansible-avalanche-getting-started" ]; then
  echo "This script has to be run after scripts/local_network.sh"
fi

source ./scripts/env_vars.sh

cd ansible-avalanche-getting-started || exit
# Install dependencies
ansible-galaxy install -r ansible_collections/ash/avalanche/requirements.yml
# Deploy the block explorer
echo "Deploying the block explorer"
sed -e "s/blockscout_blockchain_id: .*/blockscout_blockchain_id: $HOLYTERRA_CHAIN_ID/" inventories/local/group_vars/blockscout.yml -i
ansible-playbook ash.avalanche.install_blockscout_docker -i inventories/local

echo "The block explorer is available at http://$FRONTEND_IP:4000"
