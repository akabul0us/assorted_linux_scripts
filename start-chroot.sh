#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
pink='\033[0;35m'
teal='\033[0;36m'
clear_color='\033[0m'
#check for root
if [ $EUID -ne 0 ]; then
	printf "${red}Run it as root${clear_color}\n"
	exit 1
fi
#ask for chroot directory if not passed as argument
if [ -z "$1" ]; then
	read -p "Path to chroot directory: " CHROOT_DIR
else
	CHROOT_DIR="$1"
fi
#check that the directory exists
if [ ! -d "$CHROOT_DIR" ]; then
	echo "${red}Error: Chroot directory ${clear_color}$CHROOT_DIR${red} does not exist.${clear_color}\n"
	exit 1
fi
#set a variable with that directory's full path
export old_pwd="$(pwd)"
cd $CHROOT_DIR
export CHROOT_FULL_PATH="$(pwd)"
cd $old_pwd
#mount /dev
mount | grep "$CHROOT_DIR/dev" > /dev/null
dev_result="$?"
if [ "$dev_result" -eq 0 ]; then
        printf "${green}/dev${clear_color} already mounted\n"
else
        printf "Mounting ${green}/dev${clear_color}\n"
        mount --rbind /dev "$CHROOT_DIR/dev"
	mount --make-rslave "$CHROOT_DIR/dev"
fi
#mount /proc
mount | grep "$CHROOT_DIR/proc" > /dev/null
proc_result="$?"
if [ "$proc_result" -eq 0 ]; then
	printf "${pink}/proc${clear_color} already mounted\n"
else 
	printf "Mounting ${pink}/proc${clear_color}\n"
	mount -t proc /proc "$CHROOT_DIR/proc"
fi
#mount /sys
mount | grep "$CHROOT_DIR/sys" > /dev/null
sys_result="$?"
if [ "$sys_result" -eq 0 ]; then
        printf "${teal}/sys${clear_color} already mounted\n"
else
        printf "Mounting ${teal}/sys${clear_color}\n"
	mount --rbind /sys "$CHROOT_DIR/sys"
	mount --make-rslave "$CHROOT_DIR/sys"
fi
#mount /dev/pts
#uncomment if your system uses/needs this
#mount | grep "$CHROOT_DIR/dev/pts" > /dev/null
#pts_result="$?"
#if [ "$pts_result" -eq 0 ]; then
#        printf "${blue}/dev/pts${clear_color} already mounted\n"
#else
#        printf "Mounting ${blue}/dev/pts${clear_color}\n"
#	mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
#fi
# Handle unmounting on exit
cleanup() {
mount | grep -E $CHROOT_FULL_PATH | grep -oE "$CHROOT_FULL_PATH[a-z,\/]{1,}" | xargs umount -f 2>/dev/null
#any subdirectories mounted under /sys or /dev will cause unmounting those targets to fail, so we specify them last
umount -f $CHROOT_FULL_PATH/sys
umount -f $CHROOT_FULL_PATH/dev
}

# Enter the chroot
if [ -f "$CHROOT_DIR/usr/bin/zsh" ]; then
	printf "Starting ${yellow}ZSH${clear_color}\n"
	chroot "$CHROOT_DIR" /usr/bin/zsh
else
	if [ -f "$CHROOT_DIR/bin/bash" ]; then
		printf "Starting ${yellow}bash${clear_color}\n"
		chroot "$CHROOT_DIR" /bin/bash
	else
		printf "Starting ${yellow}/bin/sh${clear_color}\n"
		chroot "$CHROOT_DIR" /bin/sh || echo "Couldn't find /bin/sh in $CHROOT_DIR"
	fi
fi
trap cleanup EXIT 
