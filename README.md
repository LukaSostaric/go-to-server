# Go-to-Server
Go-to-Server is a Bash script dedicated, in the first place, to Linux system administrators who have a lot of servers and find it hard to remember all those credentials.
# Installation
Installing Go-to-Server is a breeze: Unpack the `Go-to-Server.tar.gz` archive by executing `tar xzf Go-to-Server.tar.gz` wherever you want, make all files executable with `chmod +x *`, and run the Install script by typing `./Install` in the project's directory. The interactive installation script will offer settings like the path of the configuration file, the installed program's destination, or a data file where information about servers is stored.
# Use
The installation script sets up everything that is necessary for the Go-to-Server program to be run in a "standard Linux way." To connect to a server with credentials located in the data file, type `Go-to-Server "Server-Name" ["root"]`. Please note that the `"root"` parameter is optional; it is used for logging in as `root` rather than as a normal user.
# Data File Format
    Server Name;IP Address;Username;Password;Root Password;Command for Logging in As a Superuser
    Cota;1.2.3.4;jdoe;jdoe-password;jdoe-root-password;su -
