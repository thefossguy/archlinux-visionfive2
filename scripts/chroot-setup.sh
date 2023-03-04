#!/usr/bin/env bash

tput -x clear

################################################################################
# basic chroot setup
################################################################################

# copy mirrorlist
[ -f /chroot-scripts/mirrorlist ] && cp /chroot-scripts/mirrorlist \
	/etc/pacman.d/mirrorlist

# timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# hostname
echo "archlinux" > /etc/hostname

# pacman config
sed -i "s/#Color/Color/" /etc/pacman.conf

################################################################################
# user setup
################################################################################

# setup the user riscv
useradd -m -G adm,ftp,games,http,kvm,log,rfkill,sys,systemd-journal,uucp,wheel \
	-s $(which bash) riscv

usermod --password $(echo changeme | openssl passwd -1 -stdin) riscv
passwd -e riscv

# root passwd
usermod --password $(echo root | openssl passwd -1 -stdin) root

# enable services
systemctl enable NetworkManager.service
systemctl enable sshd.service
systemctl enable dhcpcd.service

# doas setup
cat <<EOF > /etc/doas.conf
permit nopass keepenv riscv
EOF

# cleanup
rm -f /etc/machine-id
rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection


touch /etc/machine-id
