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
        password="$pass"
        superpass="$supass"
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
echo "  Connecting..."
echo "  Use '$sucommand' for root access."
ssh $options "$username@$ipaddress"
