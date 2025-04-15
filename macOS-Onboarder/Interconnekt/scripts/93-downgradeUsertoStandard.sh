#!/bin/zsh
#set -x

################################################################################################################################################
##
## Script to downgrade all users to Standard Users
## Original Location: https://github.com/microsoft/shell-intune-samples/blob/master/macOS/Config/Manage%20Accounts/downgradeUsertoStandard.sh
##
################################################################################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

##
## Notes
##
## This script can set all existing Admin accounts to be standard user accounts. The account specified in adminaccountname will not be downgraded if it is found
##
## WARNING: This script could leave your Mac will no Admin accounts configured at all

# Define variables
useraccount="itadmin"   ## Change the name of the Admin Account that you wish to be bypassed from the downgrading process (ie remains Adminstrator)
scriptname="Downgrade Admin Users to Standard"
log="/var/log/downgradeadminusers.log"
abmcheck=false   # Only downgrade users if this device is ABM managed ### Have set this to false as it was not working when true even on ABM managed devices
downgrade=true  # If set to false, script will not do anything

logandmetadir="/Library/Logs/Microsoft/IntuneScripts/downgradeAdminUsers"
log="$logandmetadir/downgradeAdminUsers.log"

function startLog() {

    ###################################################
    ###################################################
    ##
    ##  start logging - Output to log file and STDOUT
    ##
    ####################
    ####################

    if [[ ! -d "$logandmetadir" ]]; then
        ## Creating Metadirectory
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    echo "$(date) | Starting logging to [$log]"
    exec > >(tee -a "$log") 2>&1
    
}

startLog

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting $scriptname"
echo "############################################################"
echo ""

# Is this a ABM DEP device?
if [[ "$abmcheck" = true ]]; then
  downgrade=false
  echo "Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [[ ! $? == 0 ]]; then
    echo "This device is not ABM managed"
    exit 0;
  else
    echo "Device is ABM Managed"
    downgrade=true
  fi
fi

if [[ $downgrade = true ]]; then
  while read useraccount; do
    if [[ "$useraccount" == "interconnekt" ]]; then
        echo "Leaving interconnekt account as Admin"
    else
        echo "Making $useraccount a normal user"
        #/usr/sbin/dseditgroup -o edit -d $useraccount -t user admin
    fi
  done < <(dscl . list /Users UniqueID | awk '$2 >= 501 {print $1}')
fi
