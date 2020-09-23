source "$CONFIGURATION"
if [ $(echo "$0" | grep -c "copy-from-server") -eq 1 ] ; then
    if [ $# -ne 3 ] ; then
        echo "  Usage: copy-from-server <server-name> '<from-remote-path>' '<local-to-path>'"
        exit 1
    fi
    source "$DESTINATION/copy-from-to-server.sh" "$1" "$2" "$3" "copy-from"
elif [ $(echo "$0" | grep -c "copy-to-server") -eq 1 ] ; then
    if [ $# -ne 3 ] ; then
        echo "  Usage: copy-to-server <server-name> '<from-local-path>' '<to-remote-path>'"
        exit 1
    fi
    source "$DESTINATION/copy-from-to-server.sh" "$1" "$2" "$3" "copy-to"
else
    if [ $VARIANT -eq 1 ] && [ -n "$2" ] ; then
        echo "  Error: This program is not configured to take the second argument \"$1\"!"
        exit 3
    elif [ $VARIANT -eq 2 ] ; then
        source "$DESTINATION/go-to-server-with-expect.sh" "$1" "$2"
    else
        source "$DESTINATION/go-to-server.sh" "$1"
    fi
fi