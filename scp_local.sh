#!/usr/bin/env bash
#####  CONFIGURATION SECTION  #####
dev_name="dingus"
dev_port="1420"
dev_ip="192.168.1.69" #nice
dev_user="dongus"
home_dir="/home/$dev_user"
#####  END OF CONFIGURATION   #####
pwd="$(pwd)"
sendfile() {
	echo "Copying $filename to $dev_dir"
	scp -P $dev_port $filename $dev_user@$dev_ip:$dev_dir
}
getfile() {
	echo "Copying $filename from $dev_dir to $pwd"
	scp -P $dev_port $dev_user@$dev_ip:$dev_dir/$filename .
}
while getopts "sg:" flag; do
	shift
	if [[ -z "$1" ]]; then
		echo "Syntax: scp$dev_name -[sg] file (directory)"
		exit 1
	else
		 filename="$1"
	fi
	if [[ -z "$2" ]]; then
		dev_dir="$home_dir"
	else
		dev_dir="$2"
	fi
	case $flag in
		s)
			sendfile
			;;
		g)
			getfile
			;;
		\?)
			echo "Please use flag -s to send a file or -g to get one"
			exit 1
			;;
	esac
done
