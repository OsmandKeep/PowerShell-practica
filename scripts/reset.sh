#!/bin/bash

echo "Resetting firewall configuration..."

iptables -F
iptables -X

nft flush ruleset

echo "Firewall rules cleared."
