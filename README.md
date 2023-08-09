# Avalanche Warp Navigator

<p align=center>
<img src="img/navigator.png">
</p>

> A **Navigator** is a \[...\] Human mutant who possesses the Navigator Gene. This gives a Navigator the unique ability to navigate a faster-than-light starship accurately through \[[the Warp](https://warhammer40k.fandom.com/wiki/Immaterium)\]. - [Warhammer 40k Wiki](https://warhammer40k.fandom.com/wiki/Navigator)

This repository contains all the resources required to setup an local environment to run Avalanche Warp Navigator.

Avalanche Warp Navigator is an **experimental feature** of the [Ash Rust SDK](https://github.com/AshAvalanche/ash-rs) that allows to monitor all the messages sent through [Avalanche Warp Messaging](https://docs.avax.network/learn/avalanche/awm) between [Avalanche](https://www.avax.network/) [Subnet-EVM](https://github.com/ava-labs/subnet-evm) chains.

This project was created during [Avalanche Hackathon 2023 (HK)](https://www.talentre.academy/hackathon/avalanche-hackathon) on 2023-08-07 and is competing in the **Track 3: Dev Tooling**.

## Prerequisites

To try out Avalanche Warp Navigator you need to have the following software installed on your machine:

- [Multipass](https://multipass.run/) (see [Install Multipass](https://multipass.run/install))
- [Terraform](https://www.terraform.io/) (see [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- [jq](https://stedolan.github.io/jq/) (see [Download jq](https://stedolan.github.io/jq/download/))

## Useful information

The local environment is composed of:

- 5 Avalanche nodes running on Multipass VMs
- 1 Blockscout explorer running on a Multipass VM
- 1 Subnet with 2 EVM chains

The EVM chains are deployed using a custom build of the Subnet-EVM by the Ash team: [Warp-enabled Subnet-EVM](https://github.com/AshAvalanche/subnet-evm/releases/tag/v0.666.0)

## Environment setup

First of all, clone this repo:

```bash
git clone https://github.com/AshAvalanche/avalanche-warp-navigator.git --recurse-submodules
```

### Local network bootstrap

Run `scripts/local_network.sh` to bootstrap a local Avalanche test network with 5 nodes and create a Subnet with 2 EVM chains.

```bash
cd avalanche-warp-navigator
./scripts/local_network.sh
```

Source `scripts/env_vars.sh` to populate useful environment variables to interact with the local network.

```bash
source scripts/env_vars.sh
```

Run `scripts/explorer.sh` to deploy a Blockscout explorer.

```bash
./scripts/explorer.sh
```

### Environment cleanup

Run `scripts/cleanup.sh` to destroy the local network and the Blockscout explorer.

```bash
./scripts/cleanup.sh
```

## Interacting with the chains

Contracts under `contracts/` where taken from [subnet-evm/contracts](https://github.com/ava-labs/subnet-evm/tree/master/contracts).

We can interact with stateful precompiles using Hardhat tasks on the `local` network:

```bash
cd contracts
# Install dependencies
npm install

# Enable the ewoq address to deploy contracts
npx hardhat deployerAllowList:addDeployer --address 0x8db97c7cece249c2b98bdc0226cc4c2a57bf52fc --network local

# Get the bytes32 blockchain ID of the Subnet as seen by WarpMessenger
npx hardhat warpMessenger:getBlockchainID --network local
```
