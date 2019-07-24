# Go to Server
Go to Server is a Bash script dedicated, in the first place, to Linux system administrators who have a lot of servers to connect to and find it hard to remember all those credentials.
# Installation
Installing `go-to-server` is a breeze: Unpack the `go-to-server.tar.gz` archive by executing `tar xzf go-to-server.tar.gz` wherever you want, make all files executable with `chmod +x *`, and run the Install script by typing `./install.sh` in the project's directory. The interactive installation script will offer settings like the path of the configuration file, the installed program's destination, or a data file where information about servers is stored.
# Use
The installation script sets up everything that is necessary for the `go-to-server` script to be run in a "standard Linux way". Use the template `server-list` included in this package to enter your server credentials. To connect to a server with credentials located in the data file, type `go-to-server "server-name" ["root"]`. If you chose the Expect version of the script, it is possible to pass "root" as the second parameter. Please note that the `root` parameter is optional; it is used for logging in as `root` automatically through the ordinary user.
## Copying Files
The installation script also installs the tools for copying files between the user's machine and the server or vice-versa. To copy files/directories from your machine to a server `server-1`, use the following command:
    copy-to-server server-1 /from/my/machine/dir /to/server/dir
To copy files/directories from a server `server-1` to your machine, enter the following:
    copy-from-server server-1 /from/server/dir /to/my/machine/dir
# Data File Format Explanation
    Server Name;IP Address;Username;Password;Root Password;Command for Logging in As a Superuser;SSH Options;SCP Options
    server-1;1.2.3.4;jdoe;jdoe-password;jdoe-root-password;su -;-p 2233;-P 2233
