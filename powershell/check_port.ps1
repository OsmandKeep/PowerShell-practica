<#
.SYNOPSIS
    Verifies whether a network port is OPEN or CLOSED on Windows using PowerShell.
.DESCRIPTION
    Takes a target port (and optional host) and performs a TCP connection test.
.PARAMETER Port
    Port number to check (1 - 65535).
.PARAMETER Hostname
    IP address or hostname to check (default: 127.0.0.1 / localhost).
.PARAMETER TimeoutMs
    Connection timeout in milliseconds (default: 2000 ms).
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\powershell\check_port.ps1 80 google.com
.EXAMPLE
    .\powershell\check_port.ps1 9999
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $false, HelpMessage = "Port number to verify")]
    [string]$Port,

    [Parameter(Position = 1, Mandatory = $false)]
    [string]$Hostname = "127.0.0.1",

    [int]$TimeoutMs = 2000
)

# 1. Validate port input
if ([string]::IsNullOrWhiteSpace($Port)) {
    Write-Host "Error: A port number must be provided as an argument." -ForegroundColor Yellow
    Write-Host "Usage: .\check_port.ps1 <port> [host]"
    Write-Host "Examples:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\powershell\check_port.ps1 80 google.com"
    Write-Host "  .\powershell\check_port.ps1 9999"
    exit 1
}

# 2. Validate numeric port range (1-65535)
$parsedPort = 0
$isNumber = [int]::TryParse($Port, [ref]$parsedPort)

if (-not $isNumber -or $parsedPort -lt 1 -or $parsedPort -gt 65535) {
    Write-Host "Error: Port '$Port' is invalid. Must be an integer between 1 and 65535." -ForegroundColor Red
    exit 1
}

Write-Host "Checking port $parsedPort on $Hostname..." -ForegroundColor Cyan

# 3. Test TCP connection using .NET System.Net.Sockets.TcpClient
$tcpClient = New-Object System.Net.Sockets.TcpClient
try {
    $asyncResult = $tcpClient.BeginConnect($Hostname, $parsedPort, $null, $null)
    $success = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

    if ($success -and $tcpClient.Connected) {
        Write-Host "==============================================" -ForegroundColor Green
        Write-Host " [OPEN] Port $parsedPort on $Hostname is OPEN." -ForegroundColor Green
        Write-Host "==============================================" -ForegroundColor Green
        $tcpClient.EndConnect($asyncResult)
        $tcpClient.Close()
        exit 0
    } else {
        Write-Host "==============================================" -ForegroundColor Red
        Write-Host " [CLOSED] Port $parsedPort on $Hostname is CLOSED." -ForegroundColor Red
        Write-Host "==============================================" -ForegroundColor Red
        $tcpClient.Close()
        exit 1
    }
}
catch {
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host " [CLOSED] Port $parsedPort on $Hostname is CLOSED (or not responding)." -ForegroundColor Red
    Write-Host " Details: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "==============================================" -ForegroundColor Red
    $tcpClient.Close()
    exit 1
}
