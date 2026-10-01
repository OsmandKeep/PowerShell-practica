#!/bin/bash
# ==============================================================================
# Script: check_port.sh (Linux / Docker)
# Description: Checks whether a network port is OPEN or CLOSED.
# Usage: ./check_port.sh <port> [host]
# Examples:
#   ./check_port.sh 8080
#   ./check_port.sh 80 google.com
# ==============================================================================

PORT=$1
HOST=${2:-"127.0.0.1"}
TIMEOUT_SEC=2

# 1. Validate that port argument is provided
if [ -z "$PORT" ]; then
    echo "Error: A port number must be provided as an argument."
    echo "Usage: $0 <port> [host (optional, default: 127.0.0.1)]"
    exit 1
fi

# 2. Validate numeric port range (1-65535)
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: Port '$PORT' is invalid. Must be an integer between 1 and 65535."
    exit 1
fi

echo "Checking port $PORT on $HOST..."

# 3. Test TCP connection using native Bash /dev/tcp with timeout
if timeout "$TIMEOUT_SEC" bash -c "</dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo "=============================================="
    echo " [OPEN] Port $PORT on $HOST is OPEN."
    echo "=============================================="
    exit 0
else
    echo "=============================================="
    echo " [CLOSED] Port $PORT on $HOST is CLOSED."
    echo "=============================================="
    exit 1
fi
