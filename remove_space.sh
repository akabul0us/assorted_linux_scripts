#!/usr/bin/env bash
green='\033[0;32m'
pink='\033[0;35m'
teal='\033[0;36m'
yellow='\033[0;33m'
clear_color='\033[0m'
printf "Renaming all files with spaces or parentheses in ${green}$(pwd)${clear_color}"
for run in {1..3}; do
  printf "."
  sleep 1
done
printf "\n"
for file in *; do 
	if [[ "$file" == *" "* ]]; then
		new_file="${file// /_}"
		printf "Renaming ${pink}$file${clear_color} to ${teal}$new_file${clear_color}\n"
		mv "$file" "$new_file"
	fi
	if [[ "$file" == *\(* ]] || [[ "$file" == *\)* ]]; then
		new_file="${file//\)/}"
                newest_file="${new_file//\(/}"
		printf "Renaming ${yellow}$file${clear_color}to ${teal}$newest_file${clear_color}\n"
                mv "$file" "$newest_file" || mv "$new_file" "$newest_file"
        fi
done
