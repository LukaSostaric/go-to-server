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
function askYesOrNo() {
    local question="$1"
    local answer=""
    while true
    do
        read -p "$question" answer
        if [ -z "$answer" ] ; then
            answer="y"
        else
            answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        fi
        if [ $answer == "y" ] ; then
            return 1
        elif [ $answer == "n" ] ; then
            return 0
        else
            echo "  Please enter 'Y' or 'N'."
        fi
    done
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
function promptForBashrc() {
    askYesOrNo "  Would you like to modify your .bashrc automatically for PATH [Y]? "
    if [ $? -eq 1 ] ; then
        echo "# -- BEGIN -- Added by the go-to-server script." >> "$HOME/.bashrc"
        echo "# This can be deleted if not using the script." >> "$HOME/.bashrc"
        echo "export PATH=$PATH:$bindir" >> "$HOME/.bashrc"
        echo "# -- END -- " >> "$HOME/.bashrc"
        notInPath="true"
    fi
}
function promptForBashComp() {
    askYesOrNo "  Would you like to modify your .bash_completion file automatically for autocomplete [Y]? "
    if [ $? -eq 1 ] ; then
        if [ -f "$completion" ] ; then
            echo > "$completion"
            cat completion.sh >> "$completion"
        else
            cat completion.sh > "$completion"
        fi
        sed -i "s#SRVLISTPATH#$datafile#" "$completion"
        bcompmod="true"
    fi
}
# Script Start
user=$(whoami)
notInPath="false"
askForBashrc="false"
askForAutocomp="true"
bcompmod="false"
if [ $user = "root" ] ; then
    echo "  WARNING: You are running this installation as the root user. That's not recommended. It's better to install Go to Server as an ordinary user."
    destination="/opt/go-to-server"
    configuration="/etc/opt/go-to-server/configuration"
    datafile="/etc/opt/go-to-server/server-list"
    bindir="/usr/local/bin"
    completion="/usr/share/bash-completion/completions/go-to-server"
else
    destination="$HOME/.go-to-server"
    configuration="$HOME/.go-to-server/configuration"
    datafile="$HOME/.go-to-server/server-list"
    bindir="${destination}/bin"
    completion="$HOME/.bash_completion"
    if [ $(echo "$PATH" | grep -c "$bindir") -eq 0 ] ; then
        askForBashrc="true"
    fi
fi
dstPrompt="  Destination directory (default -- $destination): "
confPrompt="  Configuration file (default -- $configuration): "
dfprompt="  Server list file (default -- $datafile): "
destination=$(readInput "$dstPrompt" 1 "$destination" "$user")
configuration=$(readInput "$confPrompt" 0 "$configuration" "$user")
datafile=$(readInput "$dfprompt" 0 "$datafile" "$user")
variant=1
while true
do
    echo "  1) Program with Xclip (recommended)"
    echo "  2) Program with Expect"
    echo -n "  Choose your variant (default -- $variant): "
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
        echo "  Invalid choice. It can be either 1 or 2."
    fi
done
if [ $askForBashrc == "true" ] ; then
    promptForBashrc
fi
if [ $askForAutocomp == "true" ] ; then
    promptForBashComp
fi
position="$(echo "$destination" | grep -Fob "/" | tail -1 | cut -d ":" -f 1-1)"
ddirectory="${destination:0:position}"
position="$(echo "$configuration" | grep -Fob "/" | tail -1 | cut -d ":" -f 1-1)"
position=$(($position + 1))
cdirectory="${configuration:0:position}"
mkdir -p "$ddirectory"
mkdir -p "$cdirectory"
mkdir -p "$bindir"
cp go-to-server.sh go-to-server-configured.sh go-to-server-with-expect.sh copy-from-to-server.sh "$ddirectory"
if [ ! -f "$datafile" ] ; then
    cat server-list > "$datafile"
fi
if [ "$user" == "root" ] ; then
    chmod 644 "$datafile"
else
    chmod 600 "$datafile"
fi
echo "DF=\"$datafile\" ## The path to a file with server information" > $configuration
echo "VARIANT=$variant ## Variant of the program to run" >> $configuration
content=$(cat $ddirectory/go-to-server-configured.sh)
cat <<EOF > "$ddirectory/go-to-server-configured.sh"
#!/bin/bash
DESTINATION="${ddirectory}"
CONFIGURATION="${configuration}"
${content}
EOF
ln -s "$ddirectory/go-to-server-configured.sh" "$bindir/go-to-server" 2> /dev/null
ln -s "$ddirectory/go-to-server-configured.sh" "$bindir/copy-from-server" 2> /dev/null
ln -s "$ddirectory/go-to-server-configured.sh" "$bindir/copy-to-server" 2> /dev/null
if [ $? -eq 0 ] ; then
    echo "  Done. The script has been installed successfully in '$ddirectory'."
    echo "  Symbolic links were added to '$bindir'."
    if [ "$notInPath" == "true" ] ; then
        echo "  The script has been added to PATH in your .bashrc file."
        echo "  Execute 'source ~/.bashrc' to refresh your PATH."
    fi
    if [ "$bcompmod" == "true" ] ; then
        echo "  Your .bash_completion file has been modified for autocomplete."
    fi
    echo "  Use the file $datafile as a template for entering your credentials."
fi
