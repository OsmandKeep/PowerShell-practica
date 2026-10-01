# Port Status Checker: Linux (Docker) & Windows (PowerShell)

## Description

This project provides two solutions to verify whether a specific network port is **OPEN** or **CLOSED**:
1. **Linux Shell Script** running inside a Docker container.
2. **Windows PowerShell Script** running natively on Windows.

---

## Project Structure

```text
docker-firewall/
│
├── shellscript/
│   └── check_port.sh            # Bash script for Linux / Docker
│
├── powershell/
│   └── check_port.ps1           # PowerShell script for Windows
│
├── Dockerfile                   # Ubuntu-based Linux image
├── docker-compose.yml           # Docker Compose configuration
└── README.md
```

---

## 1. Linux Implementation (Shell Script + Docker)

### Script: `shellscript/check_port.sh`

The script accepts a port number as its argument (and an optional host, default: `127.0.0.1`). It uses native Bash TCP sockets (`/dev/tcp/$HOST/$PORT`) with a 2-second timeout to check connectivity.

### Execution with Docker

Build the Docker image:
```bash
docker build -t firewall-lab .
```

#### Test a closed port:
```bash
docker run --rm firewall-lab /lab/shellscript/check_port.sh 9999
```
*Expected output: `[CLOSED] Port 9999 on 127.0.0.1 is CLOSED.`*

#### Test an open port (e.g., port 80 on google.com):
```bash
docker run --rm firewall-lab /lab/shellscript/check_port.sh 80 google.com
```
*Expected output: `[OPEN] Port 80 on google.com is OPEN.`*

#### Interactive container execution:
```bash
docker run -it --rm firewall-lab bash
./shellscript/check_port.sh 80 google.com
exit
```

---

## 2. Windows Implementation (PowerShell)

### Script: `powershell/check_port.ps1`

The PowerShell script accepts a port number (and optional host, default: `127.0.0.1`). It uses .NET `System.Net.Sockets.TcpClient` to perform a fast, reliable TCP connection check with timeout handling.

### Execution in Windows PowerShell

Open PowerShell in the project directory and run:

#### Test an open port (Recommended execution command):
```powershell
powershell -ExecutionPolicy Bypass -File .\powershell\check_port.ps1 80 google.com
```
*Expected output: `[OPEN] Port 80 on google.com is OPEN.`*

#### Test a closed port:
```powershell
powershell -ExecutionPolicy Bypass -File .\powershell\check_port.ps1 9999
```
*Expected output: `[CLOSED] Port 9999 on 127.0.0.1 is CLOSED.`*

#### Direct script invocation:
```powershell
.\powershell\check_port.ps1 80 google.com
.\powershell\check_port.ps1 -Port 80 -Hostname "google.com"
```
