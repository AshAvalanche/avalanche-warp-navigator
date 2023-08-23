#!/bin/bash

# This script sets up the environment variables needed to use this repository
# It is meant to be sourced

TERRAFORM_DIR=${TERRAFORM_DIR:-ansible-avalanche-getting-started/terraform/multipass}

# Avalanche endpoint
AVALANCHE_ENDPOINT="$(terraform -chdir=$TERRAFORM_DIR output -json validators_ips | jq -r '.[0]'):9650"
FRONTEND_IP="$(terraform -chdir=$TERRAFORM_DIR output -raw frontend_ip)"

# Warp Subnet and chains information
WARP_SUBNET=$(multipass exec validator01 -- ash avalanche subnet list --json | jq 'map(select(.id != "11111111111111111111111111111111LpoYY")) | .[0]')
HOLYTERRA_CHAIN=$(echo "$WARP_SUBNET" | jq '.blockchains[] | select(.name == "HolyTerra")')
FENRIS_CHAIN=$(echo "$WARP_SUBNET" | jq '.blockchains[] | select(.name == "Fenris")')

# Warp Subnet and chains IDs
WARP_SUBNET_ID=$(echo "$WARP_SUBNET" | jq -r '.id')
HOLYTERRA_CHAIN_ID=$(echo "$HOLYTERRA_CHAIN" | jq -r '.id')
FENRIS_CHAIN_ID=$(echo "$FENRIS_CHAIN" | jq -r '.id')

# Generate the RPC URI for Hardhat
RPC_URI="http://$AVALANCHE_ENDPOINT/ext/bc/$HOLYTERRA_CHAIN_ID/rpc"
# Set the EVM chain ID
CHAIN_ID=66666

export AVALANCHE_ENDPOINT
export FRONTEND_IP
export SUBNET_INFO
export HOLYTERRA_INFO
export FENRIS_INFO
export WARP_SUBNET_ID
export HOLYTERRA_CHAIN_ID
export FENRIS_CHAIN_ID
export RPC_URI
export CHAIN_ID
