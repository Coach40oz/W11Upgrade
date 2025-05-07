# =============================================================================
# Windows 11 Complete Compatibility Bypass Script (No ISO Required)
# =============================================================================
# Author: Ulises Paiz
# LinkedIn: https://www.linkedin.com/in/ulises-paiz/
# GitHub: Coach40oz
# =============================================================================
# Description:
# This script bypasses ALL Windows 11 hardware compatibility checks including:
# - TPM 2.0 requirement
# - Secure Boot requirement
# - Processor compatibility
# - RAM checks
# - Disk partition type (MBR vs GPT)
# - Disk space requirements
# - WDDM version check
# 
# It sets all necessary registry keys and then downloads and launches the
# Windows 11 Installation Assistant with silent parameters.
# =============================================================================
# Usage:
# - Run as Administrator
# - No parameters required
# - Creates logs in C:\Win11 directory
# - System will restart automatically when ready
# =============================================================================
# Warning:
# While this script bypasses Microsoft's hardware requirements, it does not
# guarantee system stability on unsupported hardware. Use at your own risk.
# =============================================================================

# Ensure we're running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
    Exit 1
}

# Function to check critical disk space (Windows 11 requires minimum 64GB)
function Check-DiskSpace {
    # Check free disk space on system drive
    $freeSpace = [math]::Round((Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'").FreeSpace / 1GB, 2)
    Write-Host "`n===== DISK SPACE CHECK =====" -ForegroundColor Yellow
    Write-Host "Free Disk Space: $freeSpace GB" -ForegroundColor Cyan
    
    # Critical check - Windows 11 requires 64GB minimum
    if ($freeSpace -lt 64) {
        Write-Host "WARNING: Insufficient disk space for Windows 11!" -ForegroundColor Red
        Write-Host "Windows 11 requires at least 64GB of free space, but you only have $freeSpace GB" -ForegroundColor Red
        Write-Host "The upgrade will likely fail unless you free up more space" -ForegroundColor Red
        
        $response = Read-Host "Do you want to continue anyway? (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Host "Operation cancelled by user" -ForegroundColor Yellow
            Exit 0
        }
    } else {
        Write-Host "Disk Space: Sufficient for Windows 11 installation" -ForegroundColor Green
    }
}

# Create directory if it doesn't exist
$dir = 'C:\Win11'
if (!(Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $dir" -ForegroundColor Green
}

# Check if we have enough disk space (critical requirement)
Check-DiskSpace

# Set ALL bypass registry keys BEFORE downloading the installer
try {
    Write-Host "`n===== SETTING REGISTRY BYPASS KEYS =====" -ForegroundColor Yellow
    
    # 1. Create MoSetup key if it doesn't exist (TPM/CPU Bypass)
    if (!(Test-Path "HKLM:\SYSTEM\Setup\MoSetup")) {
        New-Item -Path "HKLM:\SYSTEM\Setup" -Name "MoSetup" -Force | Out-Null
        Write-Host "Created MoSetup registry key" -ForegroundColor Green
    }
    
    # Set the registry key to bypass TPM/CPU check
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Set AllowUpgradesWithUnsupportedTPMOrCPU = 1" -ForegroundColor Green
    
    # 2. Create LabConfig key if it doesn't exist (Additional hardware checks bypass)
    if (!(Test-Path "HKLM:\SYSTEM\Setup\LabConfig")) {
        New-Item -Path "HKLM:\SYSTEM\Setup" -Name "LabConfig" -Force | Out-Null
        Write-Host "Created LabConfig registry key" -ForegroundColor Green
    }
    
    # Set additional bypass keys
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassTPMCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassSecureBootCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassRAMCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassStorageCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassCPUCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassDiskCheck" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Set all LabConfig bypass keys" -ForegroundColor Green
    
    # 3. Create PC Health Check bypass key
    if (!(Test-Path "HKCU:\Software\Microsoft\PCHC")) {
        New-Item -Path "HKCU:\Software\Microsoft" -Name "PCHC" -Force | Out-Null
        Write-Host "Created PC Health Check registry key" -ForegroundColor Green
    }
    
    # Set PC Health Check bypass
    New-ItemProperty -Path "HKCU:\Software\Microsoft\PCHC" -Name "UpgradeEligibility" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "Set UpgradeEligibility = 1" -ForegroundColor Green
    
    Write-Host "All registry bypasses for hardware checks applied successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to set registry key: $_" -ForegroundColor Red
    Exit 1
}

# Download Windows 11 Installation Assistant
try {
    Write-Host "`n===== DOWNLOADING WINDOWS 11 INSTALLATION ASSISTANT =====" -ForegroundColor Yellow
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
    Write-Host "`n===== LAUNCHING WINDOWS 11 INSTALLATION ASSISTANT =====" -ForegroundColor Yellow
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
Write-Host "`nIMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "1. If the upgrade still fails, you may need to convert your disk to GPT format" -ForegroundColor Yellow
Write-Host "2. Free up disk space if you have less than 64GB available" -ForegroundColor Yellow
Write-Host "3. For more information, view the logs in: $dir" -ForegroundColor Yellow
