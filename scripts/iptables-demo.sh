#!/bin/bash
set -e

echo "=== Clearing existing iptables rules ==="
iptables -F
iptables -X

echo "=== Creating iptables rules ==="

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

echo
echo "=== iptables rules ==="
iptables -L INPUT -n -v --line-numbers
