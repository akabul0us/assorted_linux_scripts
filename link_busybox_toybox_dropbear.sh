#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
pink='\033[0;35m'
teal='\033[0;36m'
clear_color='\033[0m'
displayhelp() {
	printf "${pink}$0${clear_color}: a script to set up a complete Unix-like environment by creating links to three multi-bin programs: ${yellow}busybox${clear_color}, ${blue}toybox${clear_color}, and ${teal}dropbearmulti${clear_color}.\n"
	printf 'Usage: ' 
	printf "$0" 
	printf ' -i INSTALL DIRECTORY -b PATH TO BINARIES -p [busybox/toybox]' 
	printf "\n"
	echo "If no installation directories or path to binaries are provided, the present directory is assumed for both."
	echo "There are many applets which can be provided either by toybox or by busybox. Choose which to link to with -p busybox or -p toybox."
	exit 1
}
while getopts "i:b:p:h" option; do
	case $option in 
		i) 
			installpath="$OPTARG"
			;;
		b)
			binpath="$OPTARG"
			;;
		p)
			preference="$OPTARG"
			;;
		h)
			displayhelp
			;;
		*)
			printf "unknown option: ${red}$option${clear_color}\n"
			displayhelp
			;;
	esac
done
shift $((OPTIND -1))
if [ -z "$installpath" ]; then
	installpath="$(pwd)"
fi
if [ -z "$binpath" ]; then
	binpath="$(pwd)"
fi
files="dropbearmulti busybox toybox"
for f in $files; do
	if [ ! -f "$binpath/$f" ]; then
		printf "${red}$f${clear_color} not found in $binpath\n"
		exit 1
	fi
done
commonbins="[ arch ascii base32 base64 basename blkdiscard blkid blockdev bunzip2 bzcat cal cat chattr chgrp chmod chown chroot chrt chvt cksum clear cmp comm cp cpio crc32 cut date dd deallocvt devmem df dirname dmesg dnsdomainname dos2unix du echo egrep eject env expand factor fallocate false fgrep find flock fold free freeramdisk fsfreeze fsync ftpget ftpput getopt grep groups gunzip halt hd head hexedit hostname httpd hwclock i2cdetect i2cdump i2cget i2cset i2ctransfer id ifconfig insmod install ionice kill killall killall5 link linux32 ln logger login logname losetup ls lsattr lsmod lspci lsusb makedevs md5sum microcom mkdir mkfifo mknod mkpasswd mkswap mktemp modinfo mount mountpoint mv nbd-client nc netstat nice nl nohup nologin nproc nsenter od openvt partprobe paste patch pgrep pidof ping ping6 pivot_root pkill pmap poweroff printenv printf ps pwd pwdx readahead readlink realpath reboot renice reset rev rm rmdir rmmod rtcwake sed seq setfattr setsid sha1sum sha256sum sha3sum sha512sum shred shuf sleep sort split stat strings su swapoff swapon switch_root sync sysctl tac tail tar taskset tee test time timeout top touch true truncate ts tsort tty tunctl umount uname uniq unix2dos unlink unshare uptime usleep uudecode uuencode vconfig w watch watchdog wc wget which who whoami xargs xxd yes zcat"
toyboxbins="acpi count file fmt fstype getconf gpiodetect gpiofind gpioget gpioinfo gpioset help host iconv inotifyd iorenice iotop mcookie memeater mix nbd-server netcat oneit prlimit pwgen readelf rfkill sha224sum sha384sum sntp uclampset ulimit unicode uuidgen vmstat"
busyboxbins="[[ acpid add-shell addgroup adduser adjtimex arp arping ash awk bc beep bootchartd brctl bzip2 chat chpasswd chpst conspy crond crontab cryptpw cttyhack dc delgroup deluser depmod dhcprelay diff dnsd dpkg dpkg-deb dumpkmap dumpleases ed envdir envuidgid ether-wake expr fakeidentd fatattr fbset fbsplash fdflush fdformat fdisk fgconsole findfs flash_eraseall flash_lock flash_unlock flashcp fsck fsck.minix fstrim ftpd fuser getfattr getty gzip hdparm hexdump hostid hush ifdown ifenslave ifplugd ifup inetd init iostat ip ipaddr ipcalc ipcrm ipcs iplink ipneigh iproute iprule iptunnel kbd_mode klogd last less linux64 linuxrc loadfont loadkmap logread lpd lpq lpr lsof lsscsi lzcat lzma lzop makemime man mdev mesg mim mkdosfs mke2fs mkfs.ext2 mkfs.minix mkfs.vfat modprobe more mpstat mt nameif nanddump nandwrite nmeter nslookup ntpd passwd pipe_progress popmaildir powertop pscan pstree raidautorun rdate rdev readprofile reformime remove-shell resize resume route rpm rpm2cpio run-init run-parts runlevel runsv runsvdir rx script scriptreplay seedrng sendmail setarch setconsole setfont setkeycodes setlogcons setpriv setserial setuidgid sh showkey slattach smemcap softlimit ssl_client start-stop-daemon stty sulogin sum sv svc svlogd svok syslogd tc tcpsvd telnet telnetd tftp tftpd tr traceroute traceroute6 tree ttysize ubiattach ubidetach ubimkvol ubirename ubirmvol ubirsvol ubiupdatevol udhcpc udhcpc6 udhcpd udpsvd uevent unexpand unlzma unxz unzip users vi vlock volname wall whois xz xzcat zcip"
dropbearbins="dropbear dropbearkey dropbearconvert ssh scp dbclient ssh-keygen"
for b in $busyboxbins; do
	if [ ! -f "$installpath/$b" ]; then
		printf "Linking ${yellow}busybox${clear_color} at $installpath/${yellow}$b${clear_color}\n"
		ln -s $binpath/busybox $installpath/$b
	else
		printf "There is already a file named ${red}$b${clear_color} in $installpath\n"
	fi
done
for t in $toyboxbins; do
	if [ ! -f "$installpath/$t" ]; then
		printf "Linking ${blue}toybox${clear_color} at $installpath/${blue}$t${clear_color}\n"
		ln -s $binpath/toybox $installpath/$t
	else
		printf "There is already a file named ${red}$t${clear_color} in $installpath\n"
	fi
done
for d in $dropbearbins; do
	if [ ! -f "$installpath/$d" ]; then
		printf "Linking ${teal}dropbearmulti${clear_color} at $installpath/${teal}$d${clear_color}\n"
		ln -s $binpath/dropbearmulti $installpath/$d
	else
		printf "There is already a file named ${red}$d${clear_color} in $installpath\n"
	fi
done
if [[ "$preference" == "toybox" ]]; then
	for c in $commonbins; do
		if [ ! -f "$installpath/$c" ]; then
			printf "Linking ${blue}toybox${clear_color} at $installpath/${blue}$c${clear_color}\n"
			ln -s $binpath/toybox $installpath/$c
		else
			printf "There is already a file named ${red}$c${clear_color} in $installpath\n"
		fi
	done
elif [[ "$preference" == "busybox" ]]; then
	for c in $commonbins; do
		if [ ! -f "$installpath/$c" ]; then
			printf "Linking ${yellow}busybox${clear_color} at $installpath/${yellow}$c${clear_color}\n"
			ln -s $binpath/busybox $installpath/$c
		else
			printf "There is already a file named ${red}$c${clear_color} in $installpath\n"
		fi
	done
else
	printf "Unknown preference: ${red}$preference${clear_color}\n"
	printf "Not linking ${red}$commonbins${clear_color}\n"
	displayhelp
fi
