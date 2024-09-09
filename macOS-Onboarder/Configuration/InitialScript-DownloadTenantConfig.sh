#!/bin/bash

# Step 1: Read the value for AccountDisplayName from com.apple.extensiblesso plist
PLATFORM_SSO_PLIST="/Library/Managed Preferences/com.apple.extensiblesso.plist"
ACCOUNT_DISPLAY_NAME=$(defaults read "$PLATFORM_SSO_PLIST" "AccountDisplayName")

## Check if AccountDisplayName is empty
if [ -z "$AccountDisplayName" ]; then
  echo "AccountDisplayName not found."
  exit 1
fi

# Step 3: Compare AccountDisplayName against the JSON entries
TENANT=$(grep -A 1 "\"AccountDisplayName\": \"$ACCOUNT_DISPLAY_NAME\"" "$JSON_FILE" | grep "ShortName" | awk -F ': ' '{print $2}' | tr -d '",')

# Check if TENANT is empty
if [ -z "$TENANT" ]; then
  echo "AccountDisplayName does not match any valid tenants."
  exit 1
fi

# Step 4: Determine the URL for the specific plist file based on TENANT
BASE_URL="https://github.com/joelkino/macOS-Onboarder/raw/main/macOS-Onboarder/Configuration/Tenant-Plists"
PLIST_URL="$BASE_URL/mIOU-$TENANT.plist"

# Step 5: Download the specific plist file
DOWNLOAD_PATH="/Library/Preferences/com.secondsonconsulting.baseline.plist"
curl -o "$DOWNLOAD_PATH" "$PLIST_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download the plist file from $PLIST_URL."
  exit 1
fi

echo "Successfully downloaded the plist file to $DOWNLOAD_PATH."

# Step 6: Run baseline pointing to the downloaded config file
BASELINE_COMMAND="/usr/local/Baseline/Baseline.sh"  # Replace with the actual command or script to run the baseline
"$BASELINE_COMMAND" --config "$DOWNLOAD_PATH"

# Check if the baseline command was successful
if [ $? -ne 0 ]; then
  echo "Failed to run the baseline with the config file $DOWNLOAD_PATH."
  exit 1
fi

echo "Successfully ran the baseline with the config file $DOWNLOAD_PATH."

# Step 4: Determine the URL for the specific plist file based on TENANT
BASE_URL="https://github.com/joelkino/macOS-Onboarder/raw/main/macOS-Onboarder/Configuration/Tenant-Plists"
PLIST_URL="$BASE_URL/mIOU-$TENANT.plist"

# Step 5: Download the specific plist file
DOWNLOAD_PATH="/Library/Preferences/com.secondsonconsulting.baseline.plist"
curl -o "$DOWNLOAD_PATH" "$PLIST_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download the plist file from $PLIST_URL."
  exit 1
fi

echo "Successfully downloaded the plist file to $DOWNLOAD_PATH."