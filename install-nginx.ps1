# install-nginx.ps1
# Created: 2025-11-24, dalthonmh
# Description:
# This script downloads and installs Nginx (Windows version) to a specified folder.
# It downloads the official Nginx ZIP file, extracts it, copies the files, and creates a version file.
#
# Requirements:
# - Run this script with PowerShell on Windows.
#
# Notes:
# - Adjust the parameters values as needed.
# - The script will create the destination folder if it does not exist.
# - Existing files in the destination may be overwritten.
#
# Usage:
#   Right-click the script and select "Run with PowerShell"
#   OR
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

if (-Not (Test-Path -Path $destination)) {
    New-Item -Path $destination -ItemType Directory -Force
}

Invoke-WebRequest -Uri $nginxUrl -OutFile $nginxZip

# Extract file in destination path
$tempPath = "$destination\temp"
Expand-Archive -Path $nginxZip -DestinationPath $tempPath -Force

$nginxFolder = Get-ChildItem -Path $tempPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if ($nginxFolder) {
    # Move files with overwrite
    Get-ChildItem -Path "$($nginxFolder.FullName)\*" -Recurse | ForEach-Object {
        $targetPath = $_.FullName.Replace($nginxFolder.FullName, $destination)

        if ($_.PSIsContainer) {
            # Create file if not exists
            if (-Not (Test-Path -Path $targetPath)) {
                New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }

    Remove-Item -Path $nginxFolder.FullName -Recurse -Force
}

Remove-Item -Path $tempPath -Recurse -Force
Remove-Item -Path $nginxZip -Force

# Create version file
$versionFile = "$destination\version-$version.txt"
if (Test-Path -Path $versionFile) {
    Remove-Item -Path $versionFile -Force
}
New-Item -Path $versionFile -ItemType "File" -Value "nginx $version" | Out-Null

Write-Host "Nginx $version installed in $destination"