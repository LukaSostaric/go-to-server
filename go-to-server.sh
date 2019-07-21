#!/bin/bash
echo "Test" | xclip 2> /dev/null
if [ $? -eq 127 ] ; then
    echo "Xclip is not installed on your system! Terminating..."
    exit 1
fi
while IFS=";" read name ipa uname pass supass suc opt
do
    if [ "$name" = "$1" ] ; then
        servername="$name"
        ipaddress="$ipa"
        username="$uname"
        password="$pass"
        superpass="$supass"
        sucommand="$suc"
        options="$opt"
    fi
done < "$DF"

if [ -z "$username" ] || [ -z "$ipaddress" ] ; then

        echo "Unknown server specified. Terminating..."
        exit 1

fi

echo -n "$password" | xclip
echo -n "$superpass" | xclip -selection clipboard
echo "Connecting..."
ssh $options "$username@$ipaddress"
