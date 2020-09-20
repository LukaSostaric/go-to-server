#!/bin/bash
echo "Test" | xclip 2> /dev/null
if [ $? -eq 127 ] ; then
    echo "  Error: Xclip is not installed on your system!"
    exit 1
fi
while IFS=";" read name ipa uname pass supass suc opt scpopt
do
    if [ "$name" = "$1" ] ; then
        ipaddress="$ipa"
        username="$uname"
        password="$(echo -n "$pass" | base64 -d)"
        superpass="$(echo -n "$supass" | base64 -d)"
        sucommand="$suc"
        options="$opt"
    fi
done < "$DF"

if [ -z "$username" ] || [ -z "$ipaddress" ] ; then

        echo "  Error: Unknown server '$1'!"
        exit 1

fi

echo -n "$password" | xclip
echo -n "$superpass" | xclip -selection clipboard
echo "  Use '$sucommand' for root access."
echo "  You can paste your password using Shift + Insert."
echo "  Paste the superuser (root) password with Ctrl + Shift + V."
echo "  Connecting..."
ssh $options "$username@$ipaddress"