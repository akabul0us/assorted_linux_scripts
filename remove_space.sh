#!/usr/bin/env bash
print_help() {
	printf "Usage: $0" '[-y] [-h] [-d DIRECTORY]' "\n"
	printf "-y: skip confirmation dialog\n"
	printf "-h: print this help\n"
	printf "-d DIRECTORY: specify which directory to rename files in\n"
	printf "(if no directory is given, default is the present directory\n"
	exit 1
}
optflag=0
while getopts 'yhd:' option; do
	case $option in 
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
echo "Finding files with spaces and/or parentheses in $directory..."
for file in $directory/*; do 
	if [[ "$file" == *" "* ]]; then
		new_file="${file// /_}"
		if [ "$optflag" -eq 1 ]; then
			echo "Renaming $file to $new_file"
			mv "$file" "$new_file" 2>/dev/null
			if [[ "$file" == *\(* ]] || [[ "$file" == *\)* ]]; then
				new_file="${file//\)/}"
                		newest_file="${new_file//\(/}"
			fi
			echo "Renaming $file to $newest_file"
                	mv "$file" "$newest_file" 2>/dev/null
			if [ "$?" -ne 0 ]; then
				mv $new_file $newest_file 2>/dev/null
			fi
		else
			read -p "Rename $file to $new_file? (Y/n)" conf
			case $conf in
				[Nn])
					echo "Skipping $file"
					;;
				*)
					echo "Renaming $file to $new_file"
					mv "$file" "$new_file"
					;;
			esac
			if [[ "$file" == *\(* ]] || [[ "$file" == *\)* ]]; then
				new_file="${file//\)/}"
                		newest_file="${new_file//\(/}"
				read -p "Rename $file to $newest_file? (Y/n)" parenconf
					case $parenconf in
						[Nn])
							echo "Skipping $file"
							;;
						*)
							echo "Renaming $file to $newest_file"
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
