#!/usr/bin/env bash

set -e

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/helper.sh
set_vars

cd $DIR/../test-tokens

: "${1?Need to set TOKEN_NAME}"
: "${2?Need to set TOKEN_SYMBOL}"

TOKEN_MANAGER_ERC_20_ADDRESS=$(cat $DIR/../src/abis/proxySchain.json | jq -r ".token_manager_erc20_address")

npx hardhat erc20 --name $1 --symbol $2 --network mainnet
npx hardhat erc20 --name $1 --symbol $2 --network schain

MAINNET_ERC_20_ADDRESS=$(cat $DIR/../test-tokens/data/ERC20Example-$1-mainnet.json | jq -r ".erc20_address")
SCHAIN_ERC_20_ADDRESS=$(cat $DIR/../test-tokens/data/ERC20Example-$1-schain.json | jq -r ".erc20_address")

npx hardhat add-minter-erc20 --token-address $SCHAIN_ERC_20_ADDRESS --address $TOKEN_MANAGER_ERC_20_ADDRESS --network schain
npx hardhat mint-erc20 --token-address $MAINNET_ERC_20_ADDRESS --receiver-address $TEST_ADDRESS --amount $MINT_AMOUNT --network mainnet
