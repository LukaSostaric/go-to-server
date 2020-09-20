#!/bin/bash
# Function definitions
function addSlash() {
    local path="$1"
    local lc=""
    lc=$(lp=$((${#path} - 1));echo ${path:lp:lp})
    if [ "$lc" != "/" ] ; then
        path="$path/"
    fi
    echo "$path"
}
function checkSuper() {
    local user="$1"
    local path="$2"
    if [ "$user" != "root" ] && [ $(echo "$path" \
            | grep -c "$HOME") -eq 0 ] ; then
        echo -n "  Error: You're not a superuser, so the path has to " 1>&2
        echo "be in your home directory: $HOME/.go-to-server" 1>&2
        return 1
    fi
    return 0
}
function readInput() {
    local prompt="$1"
    local dir="$2" # Whether to check directory paths (1 or 0)
    local default="$3"
    local user="$4"
    while true
    do
        read -p "$prompt" value
        if [ -z "$value" ] ; then
            value="$default"
        fi
        checkSuper "$user" "$value"
        if [ $? -eq 0 ] ; then
            if [ $dir -eq 1 ] ; then
                if [ -n "$value" ] ; then
                    value=$(addSlash "$value")
                else
                    value="$(addSlash "$default")"
                fi
                break
            else
                lc=$(lp=$((${#value} - 1));echo ${value:lp:1})
                if [ "$lc" = "/" ] ; then
                    echo "  Invalid file path. Please try again." 1>&2
                else
                    break
                fi
            fi
        fi
    done
    if [ -n "$value" ] ; then
        echo "$value"
    else
        echo "$default"
    fi
}
# Script Start
user=$(whoami)
notInPath="false"
if [ $user = "root" ] ; then
    destination="/opt/go-to-server"
    configuration="/etc/opt/go-to-server/configuration"
    datafile="/etc/opt/go-to-server/server-list"
    bindir="/usr/local/bin"
else
    destination="$HOME/.go-to-server"
    configuration="$HOME/.go-to-server/configuration"
    datafile="$HOME/.go-to-server/server-list"
    bindir="${destination}/bin"
    if [ $(echo "$PATH" | grep -c "$bindir") -eq 0 ] ; then
        echo "# -- BEGIN -- Added by the go-to-server script." >> "$HOME/.bashrc"
        echo "# This can be deleted if not using the script." >> "$HOME/.bashrc"
        echo "export PATH=$PATH:$bindir" >> "$HOME/.bashrc"
        echo "# -- END -- " >> "$HOME/.bashrc"
        notInPath="true"
    fi
fi
dstPrompt="  Destination directory (Default -- $destination): "
confPrompt="  Configuration file (Default -- $configuration): "
dfprompt="  Server list file (Default -- $datafile): "
destination=$(readInput "$dstPrompt" 1 "$destination" "$user")
configuration=$(readInput "$confPrompt" 0 "$configuration" "$user")
datafile=$(readInput "$dfprompt" 0 "$datafile" "$user")
variant=1
while true
do
    echo "  1) Program with Xclip"
    echo "  2) Program with Expect"
    echo -n "  Program Variant (Default -- $variant): "
    read input
    if [ -z "$input" ] ; then
        input=$variant
    fi
    if [ "$input" = "1" ] || [ "$input" = "2" ] ; then
        if [ -n "$input" ] ; then
            variant=$input
        fi
        break
    else
        echo "Invalid choice. It can be either 1 or 2."
    fi
done
position="$(echo "$destination" | grep -Fob "/"\
    | tail -1 | cut -d ":" -f 1-1)"
ddirectory="${destination:0:position}"
position="$(echo "$configuration" | grep -Fob "/" | tail -1 \
    | cut -d ":" -f 1-1)"
position=$(($position + 1))
cdirectory="${configuration:0:position}"
mkdir -p "$ddirectory"
mkdir -p "$cdirectory"
mkdir -p "$bindir"
cp go-to-server.sh go-to-server-configured.sh go-to-server-with-expect.sh\
    copy-from-to-server.sh "$ddirectory"
if [ ! -f "$datafile" ] ; then
    cat server-list > "$datafile"
fi
chmod 600 "$datafile"
echo "DF="$datafile" ## The path to a"\
    "file with server information" > $configuration
echo "VARIANT=$variant ## Variant of the program to run" >> $configuration
content="$(cat "$ddirectory/go-to-server-configured.sh")"
echo "$(echo "#!/bin/bash";echo "DESTINATION=\"$ddirectory\"";\
    echo "CONFIGURATION=\"$configuration\"";echo "$content")"\
    | cat > "$ddirectory/go-to-server-configured.sh"
ln -s "$ddirectory/go-to-server-configured.sh"\
    "$bindir/go-to-server" 2> /dev/null
ln -s "$ddirectory/go-to-server-configured.sh"\
    "$bindir/copy-from-server" 2> /dev/null
ln -s "$ddirectory/go-to-server-configured.sh"\
    "$bindir/copy-to-server" 2> /dev/null
if [ $? -eq 0 ] ; then
    echo "  Done. The script has been installed successfully in '$ddirectory'."
    echo "  Symbolic links were added to '$bindir'."
    if [ "$notInPath" == "true" ] ; then
        echo "  Please type 'source ~/.bashrc' in your console and press the "
        echo "  Enter key to reload your environment and make the script "
        echo "  available from anywhere."
    fi
    echo "  Use the file $datafile as a "
    echo "  template for entering your credentials."
fi
