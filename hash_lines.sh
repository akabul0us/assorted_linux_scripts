#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
#if you just want the md5/sha1 functions comment this next part out
if ! python3 -c "import bcrypt" > /dev/null 2>&1; then
	printf "${red}Error${clear_color}: python3 bcrypt not installed\n"
	exit 1
fi
bcrypt() {
	python3 - "$line" << EOF
import bcrypt
import sys
args = sys.argv
print(bcrypt.hashpw(args[1].encode(), bcrypt.gensalt()).decode())
EOF
}
printhelp() {
	printf "${green}$0${clear_color}: a script to hash each line of a file using MD5, SHA1, or bcrypt\n"
	printf "Usage: ${green}$0${clear_color}"
	printf ' -[msb] FILENAME [-o OUTFILE]'
	printf "\nIf no OUTFILE is specified, FILENAME (without its extension) is used with .md5, .sha1, or .bcrypt as an extension\n"
	printf "In order to use the bcrypt hashing function, you must have a Python3 interpreter and the bcrypt Python package\n"
	exit 1
}
while getopts 'o:m:s:b:h' option; do
	case $option in
		o)
			outfile="$OPTARG"
			;;
		m)
			hashfile="$OPTARG"
			algo=md5
			;;
		s)
			hashfile="$OPTARG"
			algo=sha1
			;;
		b)
			hashfile="$OPTARG"
			algo=bcrypt
			;;
		h)
			printhelp
			;;
		*)
			printf "${red}Error${clear_color}: unknown flag ${red}$option${clear_color}\n"
			printhelp
			;;
	esac
done
if [ ! -f "$hashfile" ]; then
	printf "${red}Error${clear_color}: hashfile ${red}$hashfile${clear_color} not found\n"
	exit 1
fi
if ! touch $outfile > /dev/null 2>&1; then
	filename=$(basename -- "$hashfile")
	extension="${filename##*.}"
	filename="${filename%.*}"
	outfile="${filename}.${algo}"
fi
list="$(cat $hashfile)"
if [[ "$algo" == "md5" ]]; then
	while IFS= read -r line; do (echo -n "$line" | md5sum); done <<< "$list" | cut -c -32 | tee $outfile
elif [[ "$algo" == "sha1" ]]; then
	while IFS= read -r line; do (echo -n "$line" | sha1sum); done <<< "$list" | cut -c -40 | tee $outfile
elif [[ "$algo" == "bcrypt" ]]; then
	while IFS= read -r line; do bcrypt; done <<< "$list" | tee $outfile
else
	printf "${red}Error${clear_color}: no recognized algorithm\n"
	printhelp
fi
if [ -f "$outfile" ]; then
	printf "Hashes saved to ${green}$outfile${clear_color}\n"
else
	printf "${yellow}Warning${clear_color}: hashes not saved to file\n"
fi
