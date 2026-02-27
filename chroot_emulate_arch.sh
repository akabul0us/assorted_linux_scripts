#!/usr/bin/env bash
red='\033[0;31m'
yellow='\033[0;33m'
pink='\033[0;35m'
teal='\033[0;36m'
clear_color='\033[0m'
arm_url="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/armv7/alpine-minirootfs-3.23.3-armv7.tar.gz"
armhf_url="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/armhf/alpine-minirootfs-3.23.3-armhf.tar.gz"
aarch64_url="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/aarch64/alpine-minirootfs-3.23.3-aarch64.tar.gz"
debian_url="https://cloudfront.debian.net/debian-archive/debian"
script_name="$(basename $0)"
if [ "$EUID" -ne 0 ]; then
	printf "${red}Error${clear_color}: this script must be run with root privileges\n"
	exit 1
fi
print_help() {
	printf "${pink}$script_name${clear_color}: a script to automate the creation of a chroot using a different processor architecture.\n"
	printf "This is accomplished using qemu-static, Alpine Linux when available and Debian otherwise.\n"
	printf "Set the architecture with -a ARCH and the path with -p PATH, or simply execute the script with no flags to enter interactive mode and follow the on-screen prompts.\n"
	printf "Currently supported architecture options are ${teal}mips${clear_color}, ${teal}mipsel${clear_color}, ${teal}armhf${clear_color}, ${teal}arm${clear_color}, and ${teal}aarch64${clear_color}\n"
	printf "For more information about these options, execute $script_name -h -v\n"
	exit 1
}
print_verbose_help() {
	printf "${pink}$0${clear_color}: a script to automate the creation of a chroot using a different processor architecture.\n"
	printf "If qemu for the target architecture is already installed, the only requirements are common Linux utilities such as curl and tar. If not, the script will attempt to install it via your package manager, falling back to manual installation if necessary.\n"
	printf "While this script is tested on x86_64 computers, it ought to work on any architecture with a working qemu installation for the target architecture.\n"
	printf "The references to 'hard' or 'soft' float refer to whether the processor has a floating point hardware implementation or whether it performs these operations entirely through software.\n"
	printf "Target architectures accepted are:\n"
	printf "${teal}mips${clear_color}: big-endian, 32 bit, soft float, ${yellow}Debian 10 (Buster)${clear_color}\n"
	printf "${teal}mipsel${clear_color}: little-endian, 32 bit, soft float, ${yellow}Debian 12 (Bookworm)${clear_color}\n"
	printf "${teal}armhf${clear_color}: armv7, hard float, ${yellow}Alpine Linux 3.23.3${clear_color}\n"
	printf "${teal}arm${clear_color}: armv7, soft float, ${yellow}Alpine Linux 3.23.3${clear_color}\n"
	printf "${teal}aarch64${clear_color}: arm64 (armv8-A), ${yellow}Alpine Linux 3.23.3${clear_color}\n"
	printf "Examples: Broadcom BCM96846 - arm, Amlogic S805 - armhf, EcoNet EN751221 - mips, MediaTek MT7628 - mipsel\n"
	exit 1
}
while getopts 'a:p:vh' option; do
	case $option in 
		a) 
			arch="$OPTARG"
			;;
		p)
			path="$OPTARG"
			;;
		v)
			verbose=1
			;;
		h)
			if [ "$verbose" -eq 1 ]; then
				print_verbose_help
			else
				print_help
			fi
			;;	
		?)	
			printf "${red}Error${clear_color}: unknown flag ${red}$option${clear_color}\n"
			print_help
			;;
	esac
done
if [ -z "$path" ]; then
	read -p "Directory to create and install the chroot in? " path
fi
if [ ! -d "$path" ]; then
	echo "Creating chroot directory $path"
	mkdir -p "$path"
fi
if [ -z "$arch" ]; then
	read -p "Target architecture? (arm armhf mips mipsel aarch64)" arch
fi
create_alpine_chroot() {
	printf "Creating ${yellow}Alpine${clear_color} ${teal}$arch${clear_color} chroot\n"
	cd $path
	curl -fsSL $alpine_url | tar xzf -
	cp /etc/hosts $path/etc/hosts
	cp /etc/resolv.conf $path/etc/resolv.conf
	cp $qemu_bin $path/bin/
}
create_debian_chroot() {
	if ! command -v debootstrap > /dev/null 2>&1; then
		printf "${red}Warning${clear_color}: debootstrap not found. Attempting to install...\n"
		distros="debian arch"
		for d in $distros; do
			if [ -z "$dist" ]; then
				(cat /etc/*release | grep -i $d > /dev/null) && printf "$d-based distro detected" && dist="$d"
			fi
		done
		case $dist in
			debian)
				apt-get install debootstrap binfmt-support qemu-user-binfmt $qemusystem -y
				;;
			arch)
				pacman -S --noconfirm debootstrap qemu-user-static-binfmt qemu-user-static $qemusystem
				;;
			*)



	printf "Creating ${yellow}Debian${clear_color} ${teal}$arch${clear_color} chroot\n"

case $arch in
	arm)
		qemusystem="qemu-system-arm"
		printf "Creating ${teal}arm${clear_color} chroot\n"
		cd $path
		curl -fsSL $arm_url | tar xzf -
		
