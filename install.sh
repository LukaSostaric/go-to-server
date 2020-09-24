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
    askYesOrNo "  Would you like to modify the .bashrc file automatically for PATH [Y]? "
    if [ $? -eq 1 ] ; then
        echo "# -- BEGIN -- Added by the go-to-server script." >> "$HOME/.bashrc"
        echo "# This can be deleted if not using the script." >> "$HOME/.bashrc"
        echo "export PATH=\$PATH:$bindir" >> "$HOME/.bashrc"
        echo "# -- END -- " >> "$HOME/.bashrc"
        pathModified="true"
    fi
}
function promptForBashComp() {
    askYesOrNo "  Would you like to modify/add your .bash_completion file automatically for autocomplete [Y]? "
    if [ $? -eq 1 ] ; then
        if [ -f "$completion" ] ; then
            echo > "$completion"
            cat "$sourceDir/completion.sh" >> "$completion"
        else
            cat "$sourceDir/completion.sh" > "$completion"
        fi
        sed -i "s#SRVLISTPATH#$datafile#" "$completion"
        bcompmod="true"
    fi
}
# Script Start
if [ $(grep -c "go-to-server" "$HOME/.bashrc") -ne 0 ] ; then
    echo "  Error: Go to Server is already in your .bashrc file. Please remove it first before installing again."
    exit 1
fi
runPath="$0"
position="$(echo "$0" | grep -Fob "/" | tail -1 | cut -d ":" -f 1-1)"
sourceDir="${runPath:0:position}"
user=$(whoami)
pathModified="false"
bcompmod="false"
destination="$HOME/.go-to-server"
configuration="$HOME/.go-to-server/configuration"
datafile="$HOME/.go-to-server/server-list"
bindir="${destination}/bin"
completion="$HOME/.bash_completion"
dstPrompt="  Destination directory (default -- $destination): "
confPrompt="  Configuration file (default -- $configuration): "
dfprompt="  Server list file (default -- $datafile): "
destination=$(readInput "$dstPrompt" 1 "$destination" "$user")
configuration=$(readInput "$confPrompt" 0 "$configuration" "$user")
datafile=$(readInput "$dfprompt" 0 "$datafile" "$user")
if [ -f "$completion" ] && [ $(grep -c "go-to-server" "$completion") -ne 0 ] ; then
    echo "  Error: Go to Server is already in your .bash_completion file. Please remove it first before installing again."
    exit 1
fi
if [ -d "$destination" ] ; then
    echo "Error: Go to Server is already installed in $destination! Please remove it first before installing again."
    exit 1
fi
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
promptForBashrc
promptForBashComp
position="$(echo "$destination" | grep -Fob "/" | tail -1 | cut -d ":" -f 1-1)"
ddirectory="${destination:0:position}"
position="$(echo "$configuration" | grep -Fob "/" | tail -1 | cut -d ":" -f 1-1)"
position=$(($position + 1))
cdirectory="${configuration:0:position}"
mkdir -p "$ddirectory"
mkdir -p "$cdirectory"
mkdir -p "$bindir"
cp "$sourceDir/go-to-server.sh" "$sourceDir/go-to-server-configured.sh" \
    "$sourceDir/go-to-server-with-expect.sh" "$sourceDir/copy-from-to-server.sh" "$ddirectory"
if [ ! -f "$datafile" ] ; then
    cat "$sourceDir/server-list" > "$datafile"
fi
chmod 600 "$datafile"
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
    if [ "$pathModified" == "true" ] ; then
        echo "  The script has been added to PATH in your .bashrc file."
    else
        echo "  Your script has not been added to PATH, and your .bashrc file has not been modified."
    fi
    if [ "$bcompmod" == "true" ] ; then
        echo "  Your .bash_completion file has been modified for autocomplete."
    else
        echo "  Your .bash_completion file has not been modified."
    fi
    echo "  Use the file $datafile as a template for entering your credentials."
    echo "  Please open the new terminal window to start using the script."
fi
