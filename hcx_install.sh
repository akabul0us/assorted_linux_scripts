#!/usr/bin/env bash
#script to remove outdated/broken versions of hcxtools/hcxdumptool from Kali apt repos
#and replace them with new versions built from latest sources on ZeroBeat's GitHub
tools="hcxdumptool hcxtools"
if [ $EUID -ne 0 ]; then
	echo "Run it as root"
	exit 1
fi
if [ ! -f "/etc/debian_version" ]; then
	echo "This script uses Kali's package names to install dependencies."
	echo "On distributions not based on Debian, it will simply assume that you already have the build requirements."
	echo "Continuing in five seconds"
	sleep 5
else 
	for t in $tools; do
		dpkg -l | grep '^ii' | grep $t >/dev/null
		inst="$?"
		if [ "$inst" -eq 0 ]; then
			echo "Removing current version of $t"
			apt-get remove $t -y
		fi
	done
	echo "Updating package list"
	apt-get update
	packages="git pkg-config libpcap-dev zlib1g-dev libcurl4-openssl-dev build-essential make openssl"
	apt-get install $packages -y
	bulk_install="$?"
	if [ $bulk_install -ne 0 ]; then
		echo "Bulk installation of required packages failed. Attempting one by one"
		for p in $packages; do
			apt-get install $p -y
		done
fi
for t in $tools; do
	if [ -d "$HOME/$t" ]; then
		echo "Updating repo"
		cd $HOME/$t
		git pull
	else
		echo "Cloning repo"
		cd $HOME
		git clone https://www.github.com/ZerBea/$t
	fi
	cd $HOME/$t
	echo "Building $t"
	make clean
	make -j$(nproc --all)
	make install
done
hcxtools="hcxeiutool hcxhash2cap hcxhashtool hcxpcapngtool hcxpmktool hcxpottool hcxpsktool hcxwltool whoismac wlancap2wpasec"
for h in $hcxtools; do
	if command -v $h >/dev/null 2>&1; then
		echo "$h installed at $(which $h)"
		echo "Version: $($h --version)"
	fi
done
