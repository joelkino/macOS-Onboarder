#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Run the command
/Applications/Huntress.app/Contents/MacOS/Huntress extensionctl install --preauthorize
