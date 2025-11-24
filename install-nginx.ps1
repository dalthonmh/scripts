# install-nginx.ps1
# Created: 2025-11-24, dalthonmh
# Description:
# This script downloads and installs Nginx (Windows version) to a specified folder.
# It downloads the official Nginx ZIP file, extracts it, copies the files, and creates a version file.
#
# Requirements:
# - Run this script with PowerShell on Windows.
# - The destination folder must not already exist.
#
# Notes:
# - Adjust the parameters values as needed.
#
# Usage:
#   Open PowerShell, navigate to the script folder, and run:
#     .\install-nginx.ps1
#
# Download this script:
#   wget https://raw.githubusercontent.com/dalthonmh/scripts/refs/heads/main/install-nginx.ps1 -OutFile install-nginx.ps1

# Parameters
$version = "1.28.0" # lts version
$destination = "E:\nginx"
$nginxUrl = "https://nginx.org/download/nginx-$version.zip"
$nginxZip = "$destination\nginx.zip"

Write-Host "Installing nginx version $version..."

# Strict validation
if (Test-Path -Path $destination) {
    Write-Host "Error: destination folder already exists. Aborting."
    exit
}

$tempRoot = "$env:TEMP\nginx_install_temp"
if (Test-Path $tempRoot) { Remove-Item $tempRoot -Recurse -Force }
New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null

$zipPath = "$tempRoot\nginx.zip"

Write-Host "Downloading..."
try {
    Invoke-WebRequest -Uri $nginxUrl -OutFile $zipPath -ErrorAction Stop
}
catch {
    Write-Host "Download failed."
    Remove-Item $tempRoot -Recurse -Force
    exit
}

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

$extractedFolder = Get-ChildItem -Path $tempRoot | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if (-not $extractedFolder) {
    Write-Host "Extraction error."
    exit
}

# Installation
Write-Host "Installing..."
New-Item -Path $destination -ItemType Directory -Force | Out-Null

Get-ChildItem -Path $extractedFolder.FullName -Recurse | Move-Item -Destination {
    $relativePath = $_.FullName.Substring($extractedFolder.FullName.Length)
    $targetPath = "$destination$relativePath"
    if ($_.PSIsContainer) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }
    return $targetPath
} -Force

# Cleaning
Remove-Item -Path $tempRoot -Recurse -Force
Set-Content -Path "$destination\version-$version.txt" -Value "Installed on $(Get-Date)"
Write-Host "Nginx $version installed in $destination"
