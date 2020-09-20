#!/bin/bash
if [ -n "$2" ] ; then
    if [ "$2" != "root" ] ; then
        echo "  Error: Invalid argument \"$2\"!"
        exit 2
    fi
fi
echo "Test" | expect 2> /dev/null
if [ $? -eq 127 ] ; then
    echo "  Error: Expect is not installed on your system!"
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

echo "#!/usr/bin/expect
trap {
 set rows [stty rows]
 set cols [stty columns]
 stty rows \$rows columns \$cols < \$spawn_out(slave,name)
} WINCH
spawn ssh "$options" -o StrictHostKeyChecking=no $username@$ipaddress
expect -timeout -1 \"*assword\"
send -- \"$password\r\"
if {{$2}=={root}} {
    expect \"*\$*\"
    send -- \"$sucommand\r\"
    expect \"*assword\"
    send -- \"$superpass\r\"
}
interact" > "$HOME/.go-to-server-winch-$(whoami)"
chmod 700 "$HOME/.go-to-server-winch-$(whoami)"
expect -f "$HOME/.go-to-server-winch-$(whoami)"
rm -f "$HOME/.go-to-server-winch-$(whoami)"
