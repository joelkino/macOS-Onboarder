#!/bin/sh

# Installation of mIOU, the macOS Intune Onboarding Utility, based on Baseline
#
######################################################################
# This script can be used to install Baseline directly from GitHub.
# It then attempts to match the AccountDisplayName value from the com.apple.extensiblesso.plist 
# with a Tenant by matching it with an entry from the Tenant-Matching-List.json file 
######################################################################
#
#  This script was adapted from Søren Theilgaard's Script
#  https://github.com/Theile
#  Twitter and MacAdmins Slack: @theilgaard
#
#  Some functions and code from Installomator:
#  https://github.com/Installomator/Installomator
#
######################################################################
scriptVersion="1.2"
# v.  1.2   : 2024-09-09 : Kept trying to combine with my multi-tenant config downloader script
# v.  1.1   : 2024-09-09 : Attempted to combine with my multi-tenant config downloader script
# v.  1.0   : 2024-09-09 : Initial version by Joel Kino
######################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

######################################################################
# SECTION 1: Multi-tenant config downloader script
######################################################################
######################################################################
# Set Variables here
######################################################################
# Base URL for raw content from the repository
BASEREPO_RAWURL="https://raw.githubusercontent.com/joelkino/macOS-Onboarder/main/macOS-Onboarder"           # Replace with actual base URL
# Constants, logging and caffeinate
log_message="Baseline install, v$scriptVersion"
label="Inst-v$scriptVersion"

# Step 1: Read the value for AccountDisplayName from com.apple.extensiblesso plist
PLATFORM_SSO_PLIST="/Library/Managed Preferences/com.apple.extensiblesso.plist"
ACCOUNT_DISPLAY_NAME=$(defaults read "$PLATFORM_SSO_PLIST" "AccountDisplayName")

## Check if AccountDisplayName is empty
if [ -z "$AccountDisplayName" ]; then
  echo "AccountDisplayName not found."
  exit 1
fi

# Step 2: Compare AccountDisplayName against the JSON entries
## Set the path for JSON_FILE
JSON_FILE="$BASEREPO_RAWURL/Configuration/Tenant-Plists/Tenant-Matching-List.json"
TENANT=$(grep -A 1 "\"AccountDisplayName\": \"$ACCOUNT_DISPLAY_NAME\"" "$JSON_FILE" | grep "TenantName" | awk -F ': ' '{print $2}' | tr -d '",')

# Check if TENANT is empty
if [ -z "$TENANT" ]; then
    TENANT="Generic"
fi

# Step 3: Determine the URL for the specific plist file based on TENANT
BASE_URL="$BASEREPO_RAWURL/Configuration/Tenant-Plists"
PLIST_URL="$BASE_URL/$TENANT.plist"

# Step 5: Download the specific plist file
DOWNLOAD_PATH="/Library/Managed Preferences/com.secondsonconsulting.baseline.plist"
curl -o "$DOWNLOAD_PATH" "$PLIST_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download the plist file from $PLIST_URL."
  exit 1
fi

echo "Successfully downloaded the plist file to $DOWNLOAD_PATH."

######################################################################
# SECTION 2: Download and Run Baseline.sh
######################################################################

# Constants, logging and caffeinate
log_message="Baseline install, v$scriptVersion"
label="Inst-v$scriptVersion"

log_location="/private/var/log/InstallBaseline.log"
printlog(){
    timestamp=
    if [[ "$(whoami)" == "root" ]]; then
        echo "$timestamp :: $label : $1" | tee -a $log_location
    else
        echo "$timestamp :: $label : $1"
    fi
}
printlog "[LOG-BEGIN] ${log_message}"

# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
    kill "$caffeinatepid" || true
    printlog "[LOG-END] Status $1"
    exit $1
}

# MARK: Install Baseline
name="Baseline"
printlog "$name check for installation"
# download URL, version and Expected Team ID
# Method for GitHub pkg with destFile
gitusername="SecondSonConsulting"
gitreponame="Baseline"
#printlog "$gitusername $gitreponame"
filetype="pkg"
downloadURL=$(curl -sfL "https://api.github.com/repos/$gitusername/$gitreponame/releases/latest" | grep -v NoDaemon | awk -F '"' "/browser_download_url/ && /$filetype\"/ { print \$4; exit }")
echo $downloadURL
if [[ "$(echo $downloadURL | grep -ioE "https.*.$filetype")" == "" ]]; then
    printlog "GitHub API failed, trying failover."
    #downloadURL="https://github.com$(curl -sfL "https://github.com/$gitusername/$gitreponame/releases/latest" | tr '"' "\n" | grep -i "^/.*\/releases\/download\/.*\.$filetype" | head -1)"
    downloadURL="https://github.com$(curl -sfL "$(curl -sfL "https://github.com/$gitusername/$gitreponame/releases/latest" | tr '"' "\n" | grep -i "expanded_assets" | head -1)" | tr '"' "\n" | grep -i "^/.*\/releases\/download\/.*\.$filetype" | head -1)"
fi
#printlog "$downloadURL"
appNewVersion=$(curl -sLI "https://github.com/$gitusername/$gitreponame/releases/latest" | grep -i "^location" | tr "/" "\n" | tail -1 | sed 's/[^0-9\.]//g')
echo $appNewVersion
#printlog "$appNewVersion"
expectedTeamID="7Q6XP5698G"

destFile="/usr/local/Baseline/Baseline.sh"
currentInstalledVersion="$(${destFile} --version | awk '{print $NF}' 2>/dev/null || true)"
printlog "${destFile} version: $currentInstalledVersion"
if [[ ! -e "${destFile}" || "$currentInstalledVersion" != "$appNewVersion" ]]; then
    printlog "$name not found or version not latest."
    printlog "${destFile}"
    printlog "Installing version ${appNewVersion} ..."
    # Create temporary working directory
    tmpDir="$(mktemp -d || true)"
    printlog "Created working directory '$tmpDir'"
    # Download the installer package
    printlog "Downloading $name package version $appNewVersion from: $downloadURL"
    installationCount=0
    exitCode=9
    while [[ $installationCount -lt 3 && $exitCode -gt 0 ]]; do
        curlDownload=$(curl -Ls "$downloadURL" -o "$tmpDir/$name.pkg" || true)
        curlDownloadStatus=$(echo $?)
        if [[ $curlDownloadStatus -ne 0 ]]; then
            printlog "error downloading $downloadURL, with status $curlDownloadStatus"
            printlog "${curlDownload}"
            exitCode=1
        else
            printlog "Download $name succes."
            # Verify the download
            teamID=$(spctl -a -vv -t install "$tmpDir/$name.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()' || true)
            printlog "Team ID for downloaded package: $teamID"
            # Install the package if Team ID validates
            if [ "$expectedTeamID" = "$teamID" ] || [ "$expectedTeamID" = "" ]; then
                printlog "$name package verified. Installing package '$tmpDir/$name.pkg'."
                pkgInstall=$(installer -verbose -dumplog -pkg "$tmpDir/$name.pkg" -target "/" 2>&1)
                pkgInstallStatus=$(echo $?)
                if [[ $pkgInstallStatus -ne 0 ]]; then
                    printlog "ERROR. $name package installation failed."
                    printlog "${pkgInstall}"
                    exitCode=2
                else
                    printlog "Installing $name package succes."
                    exitCode=0
                fi
            else
                printlog "ERROR. Package verification failed for $name before package installation could start. Download link may be invalid."
                exitCode=3
            fi
        fi
        ((installationCount++))
        printlog "$installationCount time(s), exitCode $exitCode"
        if [[ $installationCount -lt 3 ]]; then
            if [[ $exitCode -gt 0 ]]; then
                printlog "Sleep a bit before trying download and install again. $installationCount time(s)."
                printlog "Remove $(rm -fv "$tmpDir/$name.pkg" || true)"
                sleep 2
            fi
        else
            printlog "Download and install of $name successful."
        fi
    done
    # Remove the temporary working directory
    printlog "Deleting working directory '$tmpDir' and its contents."
    printlog "Remove $(rm -Rfv "${tmpDir}" || true)"
    # Handle installation errors
    if [[ $exitCode != 0 ]]; then
        printlog "ERROR. Installation of $name failed. Aborting."
        caffexit $exitCode
    else
        printlog "$name version $appNewVersion installed!"
    fi
else
    printlog "$name version $appNewVersion already found. Perfect!"
fi

caffexit 0

######################################################################