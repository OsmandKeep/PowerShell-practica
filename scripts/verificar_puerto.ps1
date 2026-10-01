<#
.SYNOPSIS
    Script equivalente en PowerShell para verificar si un puerto de red está abierto o cerrado en Windows.
.DESCRIPTION
    Recibe un puerto (y opcionalmente un host o IP) y realiza una prueba de conexión TCP.
.PARAMETER Port
    Número de puerto a comprobar (1 - 65535).
.PARAMETER Hostname
    Dirección IP o nombre de host a comprobar (por defecto 127.0.0.1 / localhost).
.PARAMETER TimeoutMs
    Tiempo máximo de espera en milisegundos (por defecto 2000 ms).
.EXAMPLE
    .\check_port.ps1 8080
.EXAMPLE
    .\check_port.ps1 80 google.com
.EXAMPLE
    .\check_port.ps1 -Port 443 -Hostname "github.com"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $false, HelpMessage = "Número de puerto a verificar")]
    [string]$Port,

    [Parameter(Position = 1, Mandatory = $false)]
    [string]$Hostname = "127.0.0.1",

    [int]$TimeoutMs = 2000
)

# 1. Validar si el puerto fue proporcionado
if ([string]::IsNullOrWhiteSpace($Port)) {
    Write-Host "Error: Debe proporcionar un número de puerto como argumento." -ForegroundColor Yellow
    Write-Host "Uso: .\check_port.ps1 <puerto> [host]"
    Write-Host "Ejemplos:"
    Write-Host "  .\check_port.ps1 8080"
    Write-Host "  .\check_port.ps1 80 google.com"
    exit 1
}

# 2. Validar que el puerto sea numérico y esté en el rango permitido (1-65535)
$parsedPort = 0
$isNumber = [int]::TryParse($Port, [ref]$parsedPort)

if (-not $isNumber -or $parsedPort -lt 1 -or $parsedPort -gt 65535) {
    Write-Host "Error: El puerto '$Port' no es válido. Debe ser un número entero entre 1 y 65535." -ForegroundColor Red
    exit 1
}

Write-Host "Verificando el estado del puerto $parsedPort en $Hostname..." -ForegroundColor Cyan

# 3. Intentar conexión TCP rápida usando System.Net.Sockets.TcpClient
$tcpClient = New-Object System.Net.Sockets.TcpClient
try {
    $asyncResult = $tcpClient.BeginConnect($Hostname, $parsedPort, $null, $null)
    $success = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

    if ($success -and $tcpClient.Connected) {
        Write-Host "==============================================" -ForegroundColor Green
        Write-Host " [ABIERTO] El puerto $parsedPort en $Hostname está ABIERTO." -ForegroundColor Green
        Write-Host "==============================================" -ForegroundColor Green
        $tcpClient.EndConnect($asyncResult)
        $tcpClient.Close()
        exit 0
    } else {
        Write-Host "==============================================" -ForegroundColor Red
        Write-Host " [CERRADO] El puerto $parsedPort en $Hostname está CERRADO." -ForegroundColor Red
        Write-Host "==============================================" -ForegroundColor Red
        $tcpClient.Close()
        exit 1
    }
}
catch {
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host " [CERRADO] El puerto $parsedPort en $Hostname está CERRADO (o no responde)." -ForegroundColor Red
    Write-Host " Detalle: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "==============================================" -ForegroundColor Red
    $tcpClient.Close()
    exit 1
}
