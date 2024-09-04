echo -ne "Enter device serial number :"
read serial
password=`echo $serial | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`
echo "Password: $password"