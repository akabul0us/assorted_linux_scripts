##Assorted Linux Scripts

Scripts I wrote to automate stuff on GNU/Linux devices, uploaded to this repo because uploading to GitHub Gists is annoying and nobody would ever be able to find stuff uploaded there.

Not intended to be universal -- these might not perform as expected on any of the BSDs, macOS, or Android (unless inside a GNU/Linux chroot).

•aircrack_install.sh: downloads and builds aircrack-ng suite from source.

•build_android_kernel.sh: build script from a Nethunter kernel, provided here as a base to modify for a similar repo.

·chroot_jail_setup.sh: creates a bare-bones (bash and nothing else) chroot at /jail and user 'prisoner' to allow you to forward services from another device to yours via SSH without exposing your credentials or facilitating any counterattack.

•hash_lines.sh: read one string per line from a file and output the corresponding md5, sha1, and bcrypt hash. (used in conjunction with hashcat to demonstrate the weaknesses of deprecated password hashing algorithms).

·hcx_install.sh: replace the broken/outdated version of hcxdumptool/hcxtools found in Kali Linux apt repos with one built automatically from latest sources on ZeroBeat's github.

·hcx_make_bpf.sh: turn a list of MAC addresses into a Berkley packet filter for use with hcxdumptool.

•link_busybox_toybox_dropbear.sh: create symlinks to busybox/toybox/dropbearmulti multi-program binaries. Useful on embedded devices.

•mullvad_wireguard_peers.sh: scrape all Mullvad WireGuard VPN servers and create (disabled) configurations for them on an OpenWrt router.

•prefix_triple.sh: rename binaries in a cross-compilation toolchain to begin with their target triple.

•remove_space.sh: batch rename files whose filenames contain spaces or parenthesis.

•scp_local.sh/scp_local_setup.sh: wrappers around scp to facilitate local network file transfers over SSH.

·show_ssid.sh: output human readable values from an .hc22000 file of WPA/WPA2 handshakes.

·start_chroot.sh: mount and enter a chroot environment (note: must already exist).

·test_fonts.sh: test a string to see how it looks in installed figlet fonts.

•translate_deepl.py: use the DeepL API to translate text on the command line into a variety of languages.
