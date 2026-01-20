#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
	printf "Run it as root\n"
	exit 1
fi
opsys="$(uname -s)"
if [ "$opsys" == "Linux" ]; then
	make_command="make"
	cat /etc/*release | grep -i debian > /dev/null
	is_debian="$?"
	if [ "$is_debian" -eq 0 ]; then
		distro="debian"
	elif [ -f "/etc/arch-release" ]; then
		distro="arch"
	else
		echo "Unsupported distribution detected, quitting"
		exit 1
	fi
elif [ "$opsys" == "OpenBSD" ]; then
	make_command="gmake"
	distro="openbsd"
elif [ "$opsys" == "FreeBSD" ]; then
	make_command="gmake"
	distro="freebsd"
else
	echo "Unsupported OS detected"
	echo "This script currently supports GNU/Linux distributions based on Debian or Arch, FreeBSD, and OpenBSD."
	exit 1
fi
if [ "$distro" == "debian" ]; then
	dependencies="libstdc++-14-dev build-essential autoconf automake libtool shtool libssl-dev usbutils libnl-3-dev libnl-genl-3-dev make pkg-config libpcre2-dev libsqlite3-dev hwloc libhwloc-plugins libcmocka0 libcmocka-dev curl tar"
	apt-get install $dependencies -y
	res="$?"
	if [ "$res" -ne 0 ]; then
		echo "Attempting one by one"
		for d in $dependencies; do
			apt-get install -y $d
		done
	fi
elif [ "$distro" == "arch" ]; then
	pacman -Sy base-devel libnl openssl ethtool util-linux zlib libpcap sqlite pcre2 hwloc cmocka hostapd wpa_supplicant tcpdump screen iw usbutils pciutils curl tar
elif [ "$distro" == "openbsd" ]; then
	pkg_add pkgconf shtool libtool gcc automake autoconf pcre sqlite3 openssl gmake cmocka curl tar
elif [ "$distro" == "freebsd" ]; then
	pkg install pkgconf shtool libtool gcc9 automake autoconf pcre sqlite3 openssl gmake hwloc cmocka curl tar
fi
cd $HOME
if [ ! -d "$HOME/aircrack-ng-1.7" ]; then
	curl -fsSL https://download.aircrack-ng.org/aircrack-ng-1.7.tar.gz | tar xzvf -
fi
cd $HOME/aircrack-ng-1.7
${make_command} clean
autoreconf -i
./configure --with-experimental --with-ext-scripts --prefix=/usr
${make_command} -j$(nproc --all)
${make_command} install
ldconfig
