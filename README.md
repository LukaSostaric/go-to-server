# Go to Server
Go to Server is a Bash script dedicated, in the first place, to Linux system administrators who have a lot of servers to connect to and find it hard to remember and/or manage all those credentials.

# Installation
Installing `go-to-server` is a breeze: Unpack the `go-to-server.tar.gz` archive by executing `tar xzf go-to-server.tar.gz` wherever you want, make all files executable with `chmod +x *`, and run the Install script by typing `./install.sh` in the project's directory. The interactive installation script will offer settings like the path of the configuration file, the installed program's destination, or a data file where information about servers is stored.

# How to use
The installation script sets everything up that is necessary for the `go-to-server` script to be run in a "standard Linux way". Use the `server-list` template included in this package to enter your server credentials. To connect to a server with credentials from the data file, type `go-to-server "server-name" ["root"]`. If you chose the Expect version of the script, it is possible to pass "root" as the second parameter as shown in the example. Please note that the `root` parameter is optional; it is used for logging in as `root` automatically through the ordinary user. Using the Expect version of the script is not recommended. The Xclip version is installed by default, and it is the recommended way to use this script. Use `Shift + Insert` to paste the user password and `Ctrl + Shift + V` to paste the superuser (root) password when using the recommended, Xclip version.

    go-to-server server-name

Now use the `Shift + Insert` key combination to paste your password. Then use `sudo su -` or `su -` and `Ctrl + Shift + V` to paste the root password. 

## Copying files
The installation script also installs the tools for copying files between the user's machine and the server or vice-versa. To copy files/directories from your machine to a server `server-1`, use the following command:

    copy-to-server server-1 /from/my/machine/dir /to/server/dir

To copy files/directories from a server `server-1` to your machine, enter the following:

    copy-from-server server-1 /from/server/dir /to/my/machine/dir
    
# Data file format explanation
The last two fields can be used to add SSH and SCP options respectively. For example, `-p 2233` is used to change the port to connect to with SSH; `-P 2233` is used to change the port used by the SCP tool. See `ssh(1)` and `scp(1)` for a list of all available options. Passwords have to be encoded in the `base64` format...
    
    # echo -n "jdoe-password" | base64
    amRvZS1wYXNzd29yZA==
    # echo -n "jdoe-root-password" | base64
    amRvZS1yb290LXBhc3N3b3Jk

Replace the values `jdoe-password` and `jdoe-root-password` with the values obtained using the commands given above.
    
    server-1;1.2.3.4;jdoe;jdoe-password;jdoe-root-password;su -;-p 2233;-P 2233

The final row would look as follows...

    server-1;1.2.3.4;jdoe;amRvZS1wYXNzd29yZA==;amRvZS1yb290LXBhc3N3b3Jk;su -;-p 2233;-P 2233