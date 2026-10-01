# Port Status Checker: Linux (Docker) & Windows (PowerShell)

## Description

This project provides two equivalent solutions to verify whether a specific network port is **OPEN** or **CLOSED**:
1. **Linux Shell Script** running inside a Docker container.
2. **Windows PowerShell Script** running natively on Windows.

---

## Project Structure

```text
docker-firewall/
│
├── shellscript/
│   ├── check_port.sh            # Main Bash script for Linux
│   └── verificar_puerto.sh      # Localized alias
│
├── powershell/
│   ├── check_port.ps1           # Main PowerShell script for Windows
│   └── verificar_puerto.ps1     # Localized alias
│
├── Dockerfile                   # Ubuntu-based Linux image
├── docker-compose.yml           # Docker Compose configuration
└── README.md
```

---

## 1. Linux Implementation (Shell Script + Docker)

### Script: `shellscript/check_port.sh`

The Bash script accepts a port number as its primary argument (and an optional hostname/IP, default `127.0.0.1`). It validates input parameters and uses native Bash TCP sockets (`/dev/tcp/$HOST/$PORT`) with a 2-second timeout to check connectivity.

### Execution with Docker

Build the Docker image:
```bash
docker build -t firewall-lab .
```

#### Test a closed port:
```bash
docker run --rm firewall-lab /lab/shellscript/check_port.sh 9999
```
*Expected output: `[CERRADO] El puerto 9999 en 127.0.0.1 está CERRADO.`*

#### Test an open port (e.g., port 80 on an external host):
```bash
docker run --rm firewall-lab /lab/shellscript/check_port.sh 80 google.com
```
*Expected output: `[ABIERTO] El puerto 80 en google.com está ABIERTO.`*

#### Interactive container usage:
```bash
docker run -it --rm firewall-lab bash
./shellscript/check_port.sh 80 google.com
exit
```

---

## 2. Windows Implementation (PowerShell)

### Script: `powershell/check_port.ps1`

The PowerShell script accepts a port number (and optional hostname, default `127.0.0.1`). It uses .NET `System.Net.Sockets.TcpClient` to perform a fast, reliable TCP connection check with timeout handling.

### Execution in Windows PowerShell

Open PowerShell in the project directory:

#### Test a closed port:
```powershell
.\powershell\check_port.ps1 9999
```
*Expected output: `[CERRADO] El puerto 9999 en 127.0.0.1 está CERRADO.`*

#### Test an open port:
```powershell
.\powershell\check_port.ps1 443 google.com
```
*Expected output: `[ABIERTO] El puerto 443 en google.com está ABIERTO.`*

#### Using named parameters:
```powershell
.\powershell\check_port.ps1 -Port 80 -Hostname "google.com"
```
