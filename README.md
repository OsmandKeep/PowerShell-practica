# Docker Firewall Lab: iptables vs nftables

This lab provides a Linux environment for learning and comparing:

- iptables
- nftables
- Linux network namespaces
- firewall chains
- filtering by IP
- filtering by TCP port
- connection tracking
- nftables sets
- Docker networking

## Requirements

- Docker
- Docker Compose

Check:

```bash
docker --version
docker compose version
```

## Start the lab

```bash
docker compose build
docker compose up -d
```

Enter the container:

```bash
docker exec -it firewall-lab bash
```

You should now be inside:

```text
root@<container>:/lab#
```

## 1. Inspect the environment

```bash
ip addr
ip route
iptables --version
nft --version
```

Important: modern Ubuntu commonly reports:

```text
iptables v1.8.x (nf_tables)
```

This means the iptables command may be using the nftables kernel backend.

## 2. Compare the current rules

```bash
./scripts/compare.sh
```

Or manually:

```bash
iptables -L -n -v
nft list ruleset
```

## 3. Run the iptables example

```bash
./scripts/iptables-demo.sh
```

Inspect:

```bash
iptables -L INPUT -n -v --line-numbers
```

The important rules are:

```bash
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

## 4. Run the nftables example

First reset the firewall:

```bash
./scripts/reset.sh
```

Then:

```bash
./scripts/nftables-demo.sh
```

Inspect:

```bash
nft list ruleset
```

The equivalent nftables rules are:

```text
iifname "lo" accept
ct state established,related accept
ip protocol icmp accept
tcp dport 8080 accept
```

## 5. Compare syntax

### Allow TCP port 80

iptables:

```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

nftables:

```bash
nft add rule inet firewall input tcp dport 80 accept
```

### Block an IP

iptables:

```bash
iptables -A INPUT -s 192.168.1.100 -j DROP
```

nftables:

```bash
nft add rule inet firewall input ip saddr 192.168.1.100 drop
```

### Block a TCP port

iptables:

```bash
iptables -A INPUT -p tcp --dport 23 -j DROP
```

nftables:

```bash
nft add rule inet firewall input tcp dport 23 drop
```

## 6. nftables sets

Run:

```bash
./scripts/sets-demo.sh
```

Inspect:

```bash
nft list ruleset
```

This creates:

```text
blocked_ips
    |
    +-- 192.168.1.10
    +-- 192.168.1.11
    +-- 192.168.1.12
    +-- 192.168.1.13
```

And one rule:

```text
ip saddr @blocked_ips drop
```

This is useful for demonstrating one of the important differences in the nftables rule model.

## 7. Reset everything

Run:

```bash
./scripts/reset.sh
```

This clears the lab firewall configuration.

## 8. HTTP server

Start the test HTTP server:

```bash
./scripts/start-http.sh
```

## 9. Práctica: Comprobación de Puertos (Linux & PowerShell)

Esta práctica incluye scripts para verificar si un puerto de red se encuentra **ABIERTO** o **CERRADO**.

### A. Versión Linux (Shell Script - `check_port.sh`)

Ubicación: `scripts/check_port.sh` (y en la raíz `check_port.sh`)

#### Uso dentro del contenedor o en Linux:
```bash
# Dar permisos de ejecución si es necesario
chmod +x ./scripts/check_port.sh

# Sintaxis:
./scripts/check_port.sh <puerto> [host_opcional]

# Ejemplos:
./scripts/check_port.sh 8080
./scripts/check_port.sh 80 google.com
```

#### Ejecución directa con Docker:
```bash
# Probar puerto 8080 (servidor web del lab)
docker run --rm firewall-lab /lab/scripts/check_port.sh 8080

# Probar puerto 80 hacia un host externo
docker run --rm firewall-lab /lab/scripts/check_port.sh 80 google.com
```

---

### B. Versión Windows (PowerShell - `check_port.ps1`)

Ubicación: `check_port.ps1` (y en `scripts/check_port.ps1`)

#### Uso en PowerShell (Windows):
```powershell
# Sintaxis:
.\check_port.ps1 <puerto> [host_opcional]

# Ejemplos:
.\check_port.ps1 8080
.\check_port.ps1 80 google.com
.\check_port.ps1 -Port 443 -Hostname "github.com"
```

