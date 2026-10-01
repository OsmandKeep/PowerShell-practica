#!/bin/bash
set -e

echo "=== Clearing nftables rules ==="
nft flush ruleset

nft add table inet firewall
nft add chain inet firewall input     '{ type filter hook input priority 0; policy accept; }'

echo "=== Creating IP set ==="

nft add set inet firewall blocked_ips     '{ type ipv4_addr; flags interval; }'

nft add element inet firewall blocked_ips     '{ 192.168.1.10, 192.168.1.11, 192.168.1.12, 192.168.1.13 }'

nft add rule inet firewall input     ip saddr @blocked_ips drop

echo
echo "=== nftables set and rule ==="
nft list ruleset
