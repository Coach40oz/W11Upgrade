# Windows 11 Lightweight Upgrade Script (No ISO Required)
# Forces upgrade on ineligible machines by bypassing hardware checks

# Ensure we're running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
    Exit 1
}

# Create directory if it doesn't exist
$dir = 'C:\Win11'
if (!(Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $dir" -ForegroundColor Green
}

# Set bypass registry keys BEFORE downloading the installer
try {
    # Create MoSetup key if it doesn't exist
    if (!(Test-Path "HKLM:\SYSTEM\Setup\MoSetup")) {
        New-Item -Path "HKLM:\SYSTEM\Setup" -Name "MoSetup" -Force | Out-Null
    }
    
    # Set the registry key to bypass TPM/CPU check
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Registry bypass for hardware checks applied successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to set registry key: $_" -ForegroundColor Red
    Exit 1
}

# Download Windows 11 Installation Assistant
try {
    Write-Host "Downloading Windows 11 Installation Assistant..." -ForegroundColor Yellow
    $webClient = New-Object System.Net.WebClient
    $url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
    $file = "$($dir)\Windows11InstallationAssistant.exe"
    $webClient.DownloadFile($url, $file)
    
    if (Test-Path $file) {
        $fileSize = (Get-Item $file).Length / 1MB
        Write-Host "Download completed successfully. File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    } else {
        throw "Download completed but file not found"
    }
} catch {
    Write-Host "Failed to download Windows 11 Installation Assistant: $_" -ForegroundColor Red
    Exit 1
}

# Run Windows 11 Installation Assistant with all silent parameters
try {
    Write-Host "Launching Windows 11 Installation Assistant with silent parameters..." -ForegroundColor Yellow
    Start-Process -FilePath $file -ArgumentList "/QuietInstall /SkipEULA /auto upgrade /NoRestartUI /copylogs $dir"
    Write-Host "Windows 11 Installation Assistant launched successfully" -ForegroundColor Green
    Write-Host "The upgrade process will continue in the background" -ForegroundColor Green
    Write-Host "Logs will be saved to: $dir" -ForegroundColor Yellow
} catch {
    Write-Host "Error launching Installation Assistant: $_" -ForegroundColor Red
    Exit 1
}

Write-Host "`n===== WINDOWS 11 UPGRADE INITIATED =====" -ForegroundColor Green
Write-Host "The system will be upgraded to Windows 11" -ForegroundColor White
Write-Host "The process runs in the background and will restart when ready" -ForegroundColor White
