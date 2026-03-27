#!/usr/bin/env bash
print_help() {
	printf "Usage: $0 "
    printf '[-y] [-h] [-q] [-d DIRECTORY]'
	printf "\n-y: skip confirmation dialog\n"
    echo '-h: print this help'
    printf 'q: quiet (no output)'
    printf "\n"
    printf '-d DIRECTORY: specify which directory to rename files in'
    printf "(if no directory is given, default is the present directory)\n"
	exit 1
}
optflag=0
while getopts 'qyhd:' option; do
	case $option in
		q)
			quiet="1"
			;;	
		y) 
			optflag="1"
			;;
		d)
			directory="$OPTARG"
			;;
		h)
			print_help
			;;
	esac
done
if [ -z "$directory" ]; then
	directory="$(pwd)"
fi
if [ "$quiet" -ne 1 ]; then
	echo "Finding files with spaces and/or parentheses in $directory..."
fi
for file in $directory/*; do 
	if [[ "$file" == *" "* ]]; then
		new_file="${file// /_}"
		if [ "$optflag" -eq 1 ]; then
			if [ "$quiet" -ne 1 ]; then
				echo "Renaming $file to $new_file"
			fi
			mv "$file" "$new_file" 2>/dev/null
			if [[ "$file" == *\(* ]] || [[ "$file" == *\)* ]]; then
				new_file="${file//\)/}"
                		newest_file="${new_file//\(/}"
			fi
			if [ "$quiet" -ne 1 ]; then
				echo "Renaming $file to $newest_file"
			fi
                	mv "$file" "$newest_file" 2>/dev/null
			if [ "$?" -ne 0 ]; then
				mv $new_file $newest_file 2>/dev/null
			fi
		else
			read -p "Rename $file to $new_file? (Y/n)" conf
			case $conf in
				[Nn])
					if [ "$quiet" -ne 1 ]; then
						echo "Skipping $file"
					fi
					;;
				*)
					if [ "$quiet" -ne 1 ]; then
						echo "Renaming $file to $new_file"
					fi
					mv "$file" "$new_file"
					;;
			esac
			if [[ "$file" == *\(* ]] || [[ "$file" == *\)* ]]; then
				new_file="${file//\)/}"
                		newest_file="${new_file//\(/}"
				read -p "Rename $file to $newest_file? (Y/n)" parenconf
					case $parenconf in
						[Nn])
							if [ "$quiet" -ne 1 ]; then
								echo "Skipping $file"
							fi
							;;
						*)
							if [ "$quiet" -ne 1 ]; then
								echo "Renaming $file to $newest_file"
							fi
							mv "$file" "$newest_file" 2>/dev/null
							if [ "$?" -ne 0 ]; then
								mv $new_file $newest_file
							fi
							;;
					esac
			fi
        fi
fi
done
