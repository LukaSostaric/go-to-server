#!/bin/bash
function checkSuper() {
    local user="$1"
    local path="$2"
    if [ "$user" != "root" ] && [ $(echo "$path" \
            | grep -c "$HOME") -eq 0 ] ; then
        echo -n "Error: You're not a superuser, so the path has to "
        echo "be in your home directory: $HOME/somedir"
        exit 1
    fi
}
user=$(whoami)
if [ $user = "root" ] ; then
    destination="/opt/go-to-server/"
    configuration="/etc/opt/go-to-server/configuration"
    datafile="/etc/opt/go-to-server/server-list"
    bindir="/usr/local/bin"
else
    destination="$HOME/.go-to-server/"
    configuration="$HOME/.go-to-server/configuration"
    datafile="$HOME/.go-to-server/server-list"
    bindir="$HOME/.local/bin"
fi
echo -n "Destination Directory ($destination): "
read input
if [ -n "$input" ] ; then
    destination="$input"
fi
lc=$(lp=$((${#destination} - 1));echo ${destination:lp:lp})
if [ "$lc" != "/" ] ; then
    destination="$destination/"
fi
checkSuper "$user" "$destination"
echo -n "Configuration File ($configuration): "
read input
if [ -n "$input" ] ; then
    last="$input"
fi
loop=1
while [ $loop -eq 1 ]
do
    lc=$(lp=$((${#configuration} - 1));echo ${configuration:lp:1})
    if [ "$lc" = "/" ] ; then
        echo "Invalid file path. Please try again."
        echo -n "Configuration File ($configuration): "
        read input
        if [ -in "$input" ] ; then
            last="$input"
        fi
    else
        loop=0
        if [ -n "$last" ] ; then
            configuration="$last"
        fi
    fi
    checkSuper "$user" "$configuration"
done
loop=1
while [ $loop -eq 1 ]
do
    echo -n "Data File ($datafile): "
    read input
    lc=$(lp=$((${#input} - 1));echo ${input:lp:1})
    if [ -n "$input" ] && [ "$lc" = "/" ] ; then
        echo "This is not a valid data file path! Please try again!"
    else
            loop=0
            if [ -n "$input" ] ; then
                datafile="$input"
            fi
    fi
    checkSuper "$user" "$datafile"
done
variant=1
loop=1
while [ $loop -eq 1 ]
do
    echo "1) Program with Xclip"
    echo "2) Program with Expect"
    echo -n "Program Variant (1): "
    read input
    if [ -z "$input" ] ; then
        input=$variant
    fi
    if [ "$input" = "1" ] || [ "$input" = "2" ] ; then
        loop=0
        if [ -n "$input" ] ; then
            variant=$input
        fi
    else
        echo "Invalid choice. It can be either 1 or 2."
    fi
done
position="$(echo "$destination" | grep -Fob "/"\
    | tail -1 | cut -d ":" -f 1-1)"
ddirectory="${destination:0:position}"
position="$(echo "$configuration" | grep -Fob "/"\
  | tail -1 | cut -d ":" -f 1-1)"
position=$(($position + 1))
cdirectory="${configuration:0:position}"
mkdir -p "$ddirectory"
mkdir -p "$cdirectory"
mkdir -p "$bindir"
cp go-to-server.sh go-to-server-configured.sh\
    go-to-server-with-expect.sh "$ddirectory"
if [ ! -f "$datafile" ] ; then
    cat server-list > "$datafile"
fi
echo "DF="$datafile" ## The path to a"\
    "file with server information" > $configuration
echo "VARIANT=$variant ## Variant of the program to run" >> $configuration
content="$(cat "$ddirectory/go-to-server-configured.sh")"
echo "$(echo "#!/bin/bash";echo "DESTINATION=\"$ddirectory\"";\
    echo "CONFIGURATION=\"$configuration\"";echo "$content")"\
    | cat > "$ddirectory/go-to-server-configured.sh"
ln -s "$ddirectory/go-to-server-configured.sh"\
    "$bindir/go-to-server" 2> /dev/null
