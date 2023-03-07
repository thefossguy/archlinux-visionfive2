#!/usr/bin/env bash

tput -x clear

################################################################################
# install the kernel
################################################################################

# cleanup before installing more pkgs
rm -f /var/cache/pacman/pkg/*.*

# install the kernel
cd /chroot-data/
pacman --noconfirm -U *.pkg.tar.zst
if [ $? -eq 0 ]; then
    rm *.pkg.tar.zst
    sync
    exit 0
else
    exit 1
fi
cd -


################################################################################
# basic chroot setup
################################################################################

# copy mirrorlist
[ -f /chroot-scripts/mirrorlist ] && cp /chroot-scripts/mirrorlist \
	/etc/pacman.d/mirrorlist

# time
hwclock --systohc # the VF2 has a hawdware clock; nice
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
usermod --password $(echo starfive | openssl passwd -1 -stdin) root

# enable services
systemctl enable NetworkManager.service
systemctl enable sshd.service
systemctl enable dhcpcd.service
systemctl enable systemd-timesyncd.service

# doas setup
cat <<EOF > /etc/doas.conf
permit nopass keepenv riscv
EOF

# ssh setup
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config || \
    echo "PermitRootLogin no" | tee -a /etc/ssh/sshd_config

# sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD:ALL/g" /etc/sudoers

# add the add-on USB WiFi dongle's firmware
wget https://github.com/eswincomputing/eswin_6600u/raw/master/firmware/ECR6600U_transport.bin -O /lib/firmware/ECR6600U_transport.bin

# cleanup
rm -f /etc/machine-id
rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection
touch /etc/machine-id

# vim:set ts=4 sts=4 sw=4 et:
