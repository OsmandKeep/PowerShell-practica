#!/bin/bash
set -e

echo "=== Clearing existing nftables rules ==="
nft flush ruleset

echo "=== Creating nftables firewall ==="

nft add table inet firewall

nft add chain inet firewall input     '{ type filter hook input priority 0; policy drop; }'

nft add rule inet firewall input iifname "lo" accept

nft add rule inet firewall input     ct state established,related accept

nft add rule inet firewall input     ip protocol icmp accept

nft add rule inet firewall input     tcp dport 8080 accept

echo
echo "=== nftables rules ==="
nft list ruleset
