source "$CONFIGURATION"
if [ $VARIANT -eq 1 ] && [ -n "$2" ] ; then
    echo "This program is not configured to take the second argument \"$1\"!"
    echo "Terminating..."
    exit 3
elif [ $VARIANT -eq 2 ] ; then
    source "$DESTINATION/go-to-server-with-expect.sh" "$1" "$2"
else
    source "$DESTINATION/go-to-server.sh" "$1"
fi
