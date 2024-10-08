#!/bin/sh

######################################################################
# Installation of NinjaOne Agent
# No customization below…
######################################################################
# This script can be used to install Baseline directly from GitHub.
######################################################################
#
#  This script made by Joel Kino
#  https://github.com/joelkino
#
######################################################################
scriptVersion="1.0"
# v.  1.0   : 2024-09-02 : Initial Testing version
######################################################################


# Specify the software name and download URL
softwarename="interconnektmainoffice3260d4-5.9.1001-installer.pkg"
softwarepkgdownloadurl="https://oc.ninjarmm.com/agent/installer/0a2d68ad-8dd6-4719-ad80-fa1da22afba3/interconnektmainoffice3260d4-5.9.1001-installer.pkg"

# Specify the path for temporary storage
temp_dir="/tmp"

# Create temp_dir if it doesn't exist
if [ ! -d "$temp_dir" ]; then
    mkdir -p "$temp_dir"
fi

# Specify the path to the installer package
installer_pkg="$temp_dir/$softwarename.pkg"

# Download the package
echo "Downloading $softwarename package..."
curl -o "$installer_pkg" "$softwarepkgdownloadurl"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Error: Download failed."
    exit 1
fi

# Install the package silently
echo "Installing $softwarename..."
sudo installer -pkg "$installer_pkg" -target /

# Check the installation result
if [ $? -eq 0 ]; then
    echo "Installation completed successfully."
else
    echo "Installation failed."
    exit 1
fi

# Clean up - remove the downloaded package
echo "Cleaning up..."
rm -f "$installer_pkg"

# Verify removal
if [ -e "$installer_pkg" ]; then
    echo "Error: Removal of downloaded package failed."
    exit 1
fi

echo "Removal of downloaded package successful."

exit 0