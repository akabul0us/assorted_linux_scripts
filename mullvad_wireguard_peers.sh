#!/bin/sh
#uses the values Mullvad describes here: https://mullvad.net/en/help/running-wireguard-router
#usage: ./mullvad_wireguard_peers.sh >> /etc/config/network
hosts="$(curl -fsSL https://mullvad.net/en/servers\?status\=true\&type\=wireguard | sed ':a;N;$!ba;s/hostname/\nhostname/g' | grep 'hostname:')"
#this is make a separate line for each host as that's much easier to loop through
#the second pipe to grep is to eliminate a few extra lines that snuck through
for h in $hosts; do
	description="$(printf $h | grep -oE 'fqdn:"[0-9,a-z,A-Z,\.\-]{1,}' | cut -c 7- )"
	pubkey="$(printf $h | grep -oE '[[:alnum:]\/=+]{20,}')"
	endpoint_host="$(printf $h | grep -oE '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | head -n 1)"
	#I am aware that grep -m1 exists, but for some reason OpenWrt's grep was occasionally returning 2 matches despite the flag, hence the pipe to head -n 1
	#the next check that pubkey contains something is because openvpn servers were slipping through, and they don't use pubkeys
	if [ ! -z "$pubkey" ]; then
		printf "config wireguard_WGINTERFACE\n"
		printf "\toption description '$description'\n"
		printf "\toption public_key '$pubkey'\n"
		printf "\tlist allowed_ips '0.0.0.0/0'\n"
		printf "\toption route_allowed_ips '1'\n"
		printf "\toption endpoint_host '$endpoint_host'\n"
		printf "\toption endpoint_port '51820'\n"
		printf "\toption disabled '1'\n\n"
	fi
done
