#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
fromtemplate() {
	cat <<'EOF' | sed 's/REPLACEDEVICE/'"$computer"'/g' | sed 's/REPLACEUSER/'"$username"'/g' |  sed 's/REPLACEPORT/'"$port"'/g' |  sed 's/REPLACEIP1/'"$ipaddress"'/g' | sed 's/REPLACEIP2/'"$altip"'/g' | sed 's,REPLACEDIR,'"$directory"',g' > scp$computer
#!/usr/bin/env bash
device="REPLACEDEVICE"
scriptname="scp$device"
username="REPLACEUSER"
port="REPLACEPORT"
localip="REPLACEIP1"
altlocalip="REPLACEIP2"
deftargetdir="REPLACEDIR"
unset noerrors
unset action
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
pwd="$(pwd)"
sendfile() {
	echo "Copying $filename to $targetdir"
	scp -P $port $filename $username@$localip:$targetdir
}
getfile() {
	echo "Copying $filename from $targetdir to $pwd"
	scp -P $port $username@$localip:$targetdir/$filename .
}
show_help() {
	echo "Simple wrapper around scp to copy files to/from devices in a local network. Uses -s to send files and -g to get files."
	echo "To adapt for your own devices, make a copy of this script for each one and edit the parameters in lines 2-8."
	printf "\nCurrently defined parameters for this copy are:\n"
	printf "${red}Device${clear_color}: ${green}$device${clear_color} (and therefore, script name: ${green}$scriptname${clear_color})\n"
	printf "${red}Username${clear_color}: ${green}$username${clear_color}\n"
	printf "${red}IP address${clear_color}: ${green}$localip${clear_color}\n"
	printf "${red}Port${clear_color}: ${green}$port${clear_color}\n"
	printf "${red}Default target directory${clear_color}: ${green}$deftargetdir${clear_color}\n"
	printf "\n${yellow}Example usage${clear_color}:\n"
	printf "to ${green}send${clear_color} somefile.txt to $device and save it in /tmp, use:\n"
	printf "$scriptname -s somefile.txt /tmp\n"
    printf "To ${red}get${clear_color} a file located at $deftargetdir/someotherfile.tar on $device to your current device, use:\n"
    printf "$scriptname -g someotherfile.tar\n"
	exit 1
}
while getopts "s:g:" flag; do
    shift
    if [[ -z "$1" ]]; then
        show_help
    else
        filename="$1"
    fi
    if [[ -z "$2" ]]; then
        targetdir="$deftargetdir"
    else
        targetdir="$2"
    fi
    case $flag in
        [Ss])
            action="send"
            sendfile && noerrors=1
            ;;
        [Gg])
            action="get"
            getfile && noerrors=1
            ;;
        \?)
            show_help
            ;;
    esac
done
if [ ! -z "$action" ]; then
    if [[ "$noerrors" != 1 ]]; then
        printf "${red}Error${clear_color}: scp failed, trying with alternative address $altlocalip\n"
        localip="$altlocalip"
        case $action in
            send)
                sendfile
                ;;
            get)
                getfile
                ;;
        esac
    fi
fi
EOF
}
showhelp() {
	printf "$0: a script to help create wrappers around scp for each of your devices.\n"
	printf "You can $0 with no options and it will prompt you for each value, or you can use:\n"
	printf "$0 -c COMPUTER -u USERNAME -i IPADDRESS -p PORT -d DIRECTORY\n"
	printf "ex: to create a script called scprpi that connects to raspberry@192.168.1.55 on port 1917, use:\n"
	printf "$0 -c rpi -u raspberry -i 192.168.1.55 -p 1917 -d '/home/raspberry'\n"
	printf "You may also use -a ALTERNATEIP to specify a secondard IP that device may be found on\n"
	printf "Any values not passed upon script execution will be prompted interactively\n"
	exit 1
}
while getopts "c:u:i:a:p:d:h" option; do
	shift
	case $option in
		[Cc])
			computer="$OPTARG"
			;;
		[Uu])
			username="$OPTARG"
			;;
		[Ii])
			ipaddress="$OPTARG"
			;;
		[Aa])
			altip="$OPTARG"
			;;
		[Pp])
			port="$OPTARG"
			;;
		[Dd])
			directory="$OPTARG"
			;;
		[Hh])
			showhelp
			;;
		*)
			printf "${red}Error${clear_color}: unknown option: $option\n"
			showhelp
	esac
done
if [ -z "$computer" ]; then
	read -p "Device name (this will also become part of the script name): " computer
fi
if [ -z "$username" ]; then
	read -p "Username: " username
fi
if [ -z "$ipaddress" ]; then
	read -p "IP address: " ipaddress
fi
if [ -z "$port" ]; then
	read -p "Port: " port
fi
if [ -z "$directory" ]; then
	read -p "Default directory on remote device for file transfers: " directory
fi

if [ -z "$altip" ]; then
	read -p "Do you wish to include a secondary IP address for this device? (y/N)" yorn
	case $yorn in
		[Yy])
			read -p "Secondary IP address: " altip
			;;
		*)
			altip="$ipaddress"
			;;
	esac
fi
fromtemplate
chmod +x scp$computer
printf "Script created: scp$computer\n"
exit 0
