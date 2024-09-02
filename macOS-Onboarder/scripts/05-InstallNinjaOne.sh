#!/bin/bash

# URL of the .pkg file
PKG_URL="https://oc.ninjarmm.com/agent/installer/0a2d68ad-8dd6-4719-ad80-fa1da22afba3/interconnektmainoffice3260d4-5.9.1001-installer.pkg"

# Destination path for the downloaded .pkg file
PKG_PATH="/tmp/installer.pkg"

# Download the .pkg file
curl -o "$PKG_PATH" "$PKG_URL"

# Install the .pkg file
sudo installer -pkg "$PKG_PATH" -target /

# Clean up the downloaded .pkg file
rm "$PKG_PATH"
