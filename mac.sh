#!/bin/sh
database="https://standards-oui.ieee.org/oui/oui.txt"
localdb="$HOME/.oui.txt"
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
usage() {
	printf "${yellow}Usage${clear_color}: $(basename $0) -m "
	printf '[MAC]'
	printf "\n-d: download database from $database to "
	printf '$HOME/.oui.txt (speeds up searches)'
	printf "\n-f: set alternate path to local database"
	printf "\n-l: path to a text file with a list of MAC addresses (one per line) to search"
	printf "\n-q: make output more quiet"
	printf "\n-h: print this help\n"
	exit 1
}
sanitycheck() {
	if ! (echo "$rawmac" | grep -E "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$" > /dev/null); then
		if [ ! -z "$rawmac" ]; then
			printf "${red}Error${clear_color}: Invalid MAC address: "
			echo "$rawmac"
			exit 1
		else
			usage
		fi
	fi
}
download_db() {
	if [ ! -f "$localdb" ]; then
		printf "${green}Downloading${clear_color} contents of $database to $localdb\n"
		curl -sS $database -o $localdb || (printf "${red}Something went wrong${clear_color}\n" && exit 1)
	else
		read -p "There is already a file at $localdb. Update it? (Y/n)" dlyorn
		case dlyorn in
			[Nn])
				printf "${yellow}Not updating${clear_color} $localdb\n"
				;;
			*)
				printf "${green}Updating${clear_color} $localdb from $database\n"
				curl -sS $database -o $localdb || (printf "${red}Something went wrong${clear_color}\n" && exit 1)
				;;
		esac
	fi
}
maclookup() {
	macbytes="$(echo $rawmac | tr -d ':.-' | cut -c -6)"
	if [ ! -f "$localdb" ]; then
		if [ "$quiet" -ne 1 ]; then
			printf "${green}Searching${clear_color} online database $database for $rawmac...\n"
			curl -sS $database 2>/dev/null | grep -m1 -i $macbytes || printf "Not found\n"
		else
			unset outstring
			printf "$rawmac: "
			outstring="$(curl -sS $database 2>/dev/null | grep -m1 -i $macbytes | sed 's/(base 16)//g' | tr '\t' ' ' | tr -s '[:space:]' | cut -c 8-)"
			if [ ! -z "$outstring" ]; then
				printf "$outstring \n"
			else
				printf "${red}Not found${clear_color}\n"
			fi
		fi
	else
		if [ "$quiet" -ne 1 ]; then
			printf "${green}Searching${clear_color} local database $localdb for $rawmac...\n"
			grep -i $macbytes $localdb || printf "${red}Not found${clear_color}\n"
		else
			printf "$rawmac: "
			if ! (grep -m1 -i $macbytes $localdb > /dev/null); then 
				printf "${red}Not found${clear_color}\n"
			else
				grep -m1 -i $macbytes $localdb | sed 's/(base 16)//g' | tr '\t' ' ' | tr -s '[:space:]' | cut -c 8-
			fi
		fi
	fi
}
while getopts 'df:l:m:qh' option; do
	case $option in
		d)
			download_db
			exit 0
			;;
		f)
			localdb="$OPTARG"
			;;
		l)
			maclist="$OPTARG"
			;;
		m)
			rawmac="$OPTARG"
			;;
		q)
			quiet=1
			;;
		h)
			usage
			;;
		*)
			printf "${red}Error${clear_color}:Unknown flag $option\n"
			usage
			;;
	esac
done
if [ -z "$maclist" ]; then
	sanitycheck
	maclookup
else
	while IFS= read -r line; do (unset rawmac; rawmac=$line; sanitycheck; maclookup); done < "$maclist"
fi
