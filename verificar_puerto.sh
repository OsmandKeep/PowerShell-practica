#!/bin/bash
# ==============================================================================
# Script: check_port.sh
# Descripción: Revisa si un puerto de red está abierto o cerrado en Linux/Docker.
# Uso: ./check_port.sh <puerto> [host]
# Ejemplos:
#   ./check_port.sh 8080
#   ./check_port.sh 80 google.com
# ==============================================================================

PORT=$1
HOST=${2:-"127.0.0.1"}
TIMEOUT_SEC=2

# 1. Validar que se haya ingresado el puerto como argumento
if [ -z "$PORT" ]; then
    echo "Error: Debe proporcionar un número de puerto como argumento."
    echo "Uso: $0 <puerto> [host (opcional, por defecto 127.0.0.1)]"
    exit 1
fi

# 2. Validar que el argumento sea un número de puerto válido (1-65535)
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: El puerto '$PORT' no es válido. Debe ser un número entero entre 1 y 65535."
    exit 1
fi

echo "Verificando el estado del puerto $PORT en $HOST..."

# 3. Intentar conexión TCP usando /dev/tcp (nativo de Bash)
if timeout "$TIMEOUT_SEC" bash -c "</dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo "=============================================="
    echo " [ABIERTO] El puerto $PORT en $HOST está ABIERTO."
    echo "=============================================="
    exit 0
else
    echo "=============================================="
    echo " [CERRADO] El puerto $PORT en $HOST está CERRADO."
    echo "=============================================="
    exit 1
fi
