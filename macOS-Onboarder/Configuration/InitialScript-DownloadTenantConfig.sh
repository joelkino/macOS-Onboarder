#!/bin/bash

# Step 1: Read the value for AccountDisplayName from com.apple.extensiblesso plist
PLATFORM_SSO_PLIST="/Library/Managed Preferences/com.apple.extensiblesso.plist"
ACCOUNT_DISPLAY_NAME=$(defaults read "$PLATFORM_SSO_PLIST" "AccountDisplayName")

# Check if AccountDisplayName is empty
if [ -z "$AccountDisplayName" ]; then
  echo "AccountDisplayName not found."
  exit 1
fi

# Step 2: Map AccountDisplayName to a specific tenant
case "$AccountDisplayName" in
  "x")
    TENANT="Tenant1"
    ;;
  "y")
    TENANT="Tenant2"
    ;;
  "z")
    TENANT="Tenant3"
    ;;
  *)
    echo "AccountDisplayName does not match any valid tenants."
    exit 1
    ;;
esac

# Step 3: Determine the URL for the specific plist file based on ACCOUNT_DISPLAY_NAME

## Updte the BASE_URL with the URL of the repository ##
BASE_URL="https://github.com/joelkino/macOS-Onboarder/tree/main/macOS-Onboarder/Configuration/Tenant-Plists"
PLIST_URL="$BASE_URL/mIOU-$AccountDisplayName.plist"

# Step 4: Download the specific plist file
DOWNLOAD_PATH="/Library/Preferences/com.secondsonconsulting.baseline.plist"
curl -o "$DOWNLOAD_PATH" "$PLIST_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download the plist file from $PLIST_URL."
  exit 1
fi

echo "Successfully downloaded the plist file to $DOWNLOAD_PATH."