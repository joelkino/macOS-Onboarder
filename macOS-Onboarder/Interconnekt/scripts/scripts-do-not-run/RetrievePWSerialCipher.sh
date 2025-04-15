## This script can be run on any macOS device and does not need to be run on the device you are retireving the password for
## Please note that this method is not entirely secure

echo -ne "Enter device serial number :"
read serial
password=`echo $serial | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`
echo "Password: $password"