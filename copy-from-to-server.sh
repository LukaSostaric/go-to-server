#!/bin/bash
if [ $? -eq 127 ] ; then
    echo "  Error: SSH is not installed on your system!"
    exit 1
fi
if [ $? -eq 127 ] ; then
    echo "  Error: SSHPass is not installed on your system!"
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
        scpoptions="$scpopt"
    fi
done < "$DF"

if [ -z "$username" ] || [ -z "$ipaddress" ] ; then

        echo "  Error: Unknown server '$1'!"
        exit 1

fi

echo "Connecting..."
if [ "$4" = "copy-to" ] ; then
    sshpass -p "$password" scp $scpoptions -r "$2" "$username@$ipaddress:$3"
    status=$?
elif [ "$4" = "copy-from" ] ; then
    sshpass -p "$password" scp $scpoptions -r "$username@$ipaddress:$2" "$3"
    status=$?
fi

if [ $status -eq 0 ] ; then
    echo "  Done: The content has been copied successfully."
    exit 0
else
    echo "  Error: Could not copy the content!"
    exit 1
fi
