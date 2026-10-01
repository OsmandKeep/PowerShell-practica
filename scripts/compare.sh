#!/bin/bash

echo "======================================"
echo "             IPTABLES"
echo "======================================"
iptables --version
iptables -L -n -v

echo
echo "======================================"
echo "             NFTABLES"
echo "======================================"
nft --version
nft list ruleset
