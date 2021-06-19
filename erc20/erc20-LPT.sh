#!/bin/bash
# Prerequisites
#  1. seth installed https://github.com/dapphub/dapptools/tree/master/src/seth
#
# Addresses: https://github.com/livepeer/wiki/blob/master/Deployed-Contract-Addresses.md
#
# Usage examples: 
#    ./erc20-LTP.sh  0x000000000000000000000000001 http://localhost:8545
#    ./erc20-LTP.sh  "0x000000000000000000000000001 0x000000000000000000000000002"  http://localhost:8545
#    ./erc20-LTP.sh  "`cat ACCOUNTS | awk '{printf $1" "}'`" http://localhost:8545

[[ -z "$1" ]] && { echo "Addresses missing"; exit 1; }

ADDR="${1}"
export ETH_RPC_URL=${2:-https://rpc.slock.it/goerli}

ERC20_CONTRACT=0x58b6a8a3302369daec383334672404ee733ab239
STAKE_CONTRACT=0x511bc4556d823ae99630ae8de28b9b80df90ea2e
ROUNDS_CONTRACT=0xC89fE48382F8fda6992dC590786A84275bCD1C57
ROUNDS_PROXY_CONTRACT=0x3984fc4ceEeF1739135476f625D36d6c35c40dc3
WEI=1000000000000000000

>&2 echo "ERC20 Contract Address: $ERC20_CONTRACT"
>&2 echo "Addresses: $ADDR"

current_round=`seth call $ROUNDS_PROXY_CONTRACT "currentRound()(uint256)"`
>&2 echo "LPT round: $current_round"

for addr in $ADDR; do
   #>&2 echo "Address: $addr"
   
   balance_wei=`seth call $ERC20_CONTRACT "balanceOf(address)(int256)" $addr`
   balance=`echo "scale=3; $balance_wei / $WEI" | bc`
   staked_wei=`seth call $STAKE_CONTRACT "pendingStake(address,uint256)(uint256)" $addr $current_round`
   staked=`echo "scale=3; $staked_wei / $WEI" | bc`
   echo "$addr: balance=$balance ($balance_wei) staked=$staked ($staked_wei)"
done
