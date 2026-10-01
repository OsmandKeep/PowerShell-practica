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

Esta práctica incluye scripts separados para verificar si un puerto de red se encuentra **ABIERTO** o **CERRADO**:

```text
docker-firewall/
├── shellscript/          # Scripts para Linux (Bash / Docker)
│   ├── check_port.sh
│   └── verificar_puerto.sh
├── powershell/           # Scripts para Windows (PowerShell)
│   ├── check_port.ps1
│   └── verificar_puerto.ps1
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

### A. Versión Linux (Carpeta `shellscript/`)

* **Ubicación:** `shellscript/check_port.sh` (dentro de Docker en `/lab/shellscript/check_port.sh`)

#### Ejecución con Docker:
```bash
# Probar puerto abierto hacia un servidor externo (ej. 80 google.com)
docker run --rm firewall-lab /lab/shellscript/check_port.sh 80 google.com

# Probar puerto cerrado (ej. 9999)
docker run --rm firewall-lab /lab/shellscript/check_port.sh 9999
```

#### Ejecución interactiva dentro del contenedor:
```bash
docker run -it --rm firewall-lab bash
./shellscript/check_port.sh 80 google.com
exit
```

---

### B. Versión Windows (Carpeta `powershell/`)

* **Ubicación:** `powershell/check_port.ps1`

#### Ejecución en Windows (PowerShell):
```powershell
# Probar puerto cerrado (ej. 9999)
.\powershell\check_port.ps1 9999

# Probar puerto abierto hacia un servidor externo (ej. 443 google.com)
.\powershell\check_port.ps1 443 google.com

# Usando sintaxis con parámetros nombrados
.\powershell\check_port.ps1 -Port 80 -Hostname "google.com"
```


