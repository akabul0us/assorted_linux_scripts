#!/usr/bin/env bash
tooldir="/opt/toolchains"
toolchains="x86_64-linux-musl- arm-linux-musleabi- arm-linux-musleabihf- aarch64-linux-musl- mips-linux-muslsf- mipsel-linux-muslsf-"
for t in $toolchains; do
	if [ -d "$tooldir/$t""cross/bin" ]; then
		cd "$tooldir/$t""cross/bin"
	else
		cd "$tooldir/$t""native/bin"
	fi
	for file in *; do
		if [[ "$file" != "$t"* ]]; then
			new_file="${t}${file}"
			echo "Renaming $file to $new_file"
        	        mv "$file" "$new_file"
			unset file
			unset new_file
		fi
	done
done
