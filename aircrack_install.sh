#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
    printf "Run it as root\n"
    exit 1
fi
if [ ! -e "/etc/debian_version" ]; then
	echo "This script uses Debian package manager apt to install dependencies"
	exit 1
fi
dependencies="libstdc++-14-dev build-essential autoconf automake libtool shtool libssl-dev usbutils libnl-3-dev libnl-genl-3-dev make pkg-config libpcre2-dev libsqlite3-dev hwloc libhwloc-plugins libcmocka0 libcmocka-dev curl tar"
apt-get install $dependencies -y
res="$?"
if [ "$res" -ne 0 ]; then
	echo "Attempting one by one"
	for d in $dependencies; do
	    apt-get install -y $d
    	done
fi
cd $HOME
if [ ! -d "$HOME/aircrack-ng-1.7" ]; then
	curl -fsSL https://download.aircrack-ng.org/aircrack-ng-1.7.tar.gz | tar xzvf -
fi
cd $HOME/aircrack-ng-1.7
make clean
autoreconf -i
./configure --with-experimental --with-ext-scripts --prefix=/usr
make
make install
ldconfig
