# macOS-Onboarder
A Multi-tenant macOS Intune Onboarding Tool that utilises the amazing work of the Open-Source Communityr, specifically:
- Second Son Consulting's Baseline tool
- Bart Reardon's SwiftDialog
- Installomator


## InitialScript-DownloadTenantConfig.sh

This script is designed to download a specific configuration plist file based on the AccountDisplayName value found in a managed preferences plist file on a macOS system. Here's a step-by-step explanation of what the script does:

Read AccountDisplayName from a plist file:

The script reads the value of AccountDisplayName from the plist file located at /Library/Managed Preferences/com.apple.extensiblesso.plist using the defaults read command.
The value is stored in the variable ACCOUNT_DISPLAY_NAME.
Check if AccountDisplayName is empty:

The script checks if the ACCOUNT_DISPLAY_NAME variable is empty. If it is, it prints an error message and exits with a status code of 1.
Compare AccountDisplayName against JSON entries:

The script searches for the AccountDisplayName in a JSON file (the path to which is stored in the variable JSON_FILE).
It uses grep to find the matching AccountDisplayName and extracts the corresponding ShortName value, which is stored in the variable TENANT.
Check if TENANT is empty:

The script checks if the TENANT variable is empty. If it is, it prints an error message and exits with a status code of 1.
Determine the URL for the specific plist file based on TENANT:

The script constructs the URL for the plist file based on the TENANT value. The base URL is https://github.com/joelkino/macOS-Onboarder/raw/main/macOS-Onboarder/Configuration/Tenant-Plists, and the specific plist file URL is constructed by appending /mIOU-$TENANT.plist to the base URL.
Download the specific plist file:

The script uses curl to download the plist file from the constructed URL and saves it to /Library/Preferences/com.secondsonconsulting.baseline.plist.
Check if the download was successful:

The script checks the exit status of the curl command. If the download failed (exit status is not 0), it prints an error message and exits with a status code of 1.
In summary, this script automates the process of reading a specific configuration value from a plist file, matching it against entries in a JSON file, determining the appropriate configuration file URL, and downloading that file to a specified location on the system.