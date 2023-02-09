#!/bin/bash
if [ $? -eq 127 ] ; then
    echo "  Error: SSH is not installed on your system!"
    exit 1
fi
if [ $? -eq 127 ] ; then
    echo "  Error: SSHPass is not installed on your system!"
    exit 1
fi
while IFS=";" read name ipa uname pass supass suc opt scpopt key
do
    if [ "$name" = "$1" ] ; then
        ipaddress="$ipa"
        username="$uname"
        password="$(echo -n "$pass" | base64 -d)"
        superpass="$(echo -n "$supass" | base64 -d)"
        sucommand="$suc"
        options="$opt"
        scpoptions="$scpopt"
        assword=assword
        [ -n "$key" ] && key="-i $key" && assword=passphrase
        break
    fi
done < "$DF"

if [ -z "$username" ] || [ -z "$ipaddress" ] ; then

        echo "  Error: Unknown server '$1'!"
        exit 1

fi

echo "Connecting..."
if [ "$4" = "copy-to" ] ; then
    sshpass -P$assword -p "$password" scp $key $scpoptions -r "$2" "$username@$ipaddress:$3"
    status=$?
elif [ "$4" = "copy-from" ] ; then
    sshpass -P$assword -p "$password" scp $key $scpoptions -r "$username@$ipaddress:$2" "$3"
    status=$?
fi

if [ $status -eq 0 ] ; then
    echo "  Done: The content has been copied successfully."
    exit 0
else
    echo "  Error: Could not copy the content!"
    exit 1
fi
