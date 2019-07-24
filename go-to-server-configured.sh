#!/bin/bash
DESTINATION="/home/luka/.go-to-server"
CONFIGURATION="/home/luka/.go-to-server/configuration"
#!/bin/bash
DESTINATION="/home/luka/.go-to-server"
CONFIGURATION="/home/luka/.go-to-server/configuration"
source "$CONFIGURATION"
if [ $(echo "$0" | grep -c "copy-from-server") -eq 1 ] ; then
    source "$DESTINATION/copy-from-to-server.sh" "$1" "$2" "$3" "copy-from"
elif [ $(echo "$0" | grep -c "copy-to-server") -eq 1 ] ; then
    source "$DESTINATION/copy-from-to-server.sh" "$1" "$2" "$3" "copy-to"
else
    if [ $VARIANT -eq 1 ] && [ -n "$2" ] ; then
        echo "This program is not configured to take the second argument \"$1\"!"
        echo "Terminating..."
        exit 3
    elif [ $VARIANT -eq 2 ] ; then
        source "$DESTINATION/go-to-server-with-expect.sh" "$1" "$2"
    else
        source "$DESTINATION/go-to-server.sh" "$1"
    fi
fi
