#!/usr/bin/env bash

tput -x clear

################################################################################
# install the kernel
################################################################################

# install the kernel
cd /chroot-data/
pacman --noconfirm -U *.pkg.tar.zst
if [ $? -eq 0 ]; then
    rm *.pkg.tar.zst
    sync
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
[ -z "$CONF_TIMEZONE" ] && export CONF_TIMEZONE=UTC
ln -sf /usr/share/zoneinfo/${CONF_TIMEZONE} /etc/localtime

# locale
[ -z "$CONF_LOCALE" ] && export CONF_LOCALE=en_US
echo "${CONF_LOCALE}.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# hostname
[ -z "$CONF_HOSTNAME" ] && export CONF_HOSTNAME=archlinux-riscv
echo "${CONF_HOSTNAME}" > /etc/hostname

# pacman config
sed -i "s/#Color/Color/" /etc/pacman.conf


################################################################################
# user setup
################################################################################

# setup the user
[ -z "$CONF_USER" ] && export CONF_USER=riscv
[ -z "$CONF_GROUPS" ] && export CONF_GROUPS=wheel
useradd -m -G "$CONF_GROUPS" \
	-s $(which bash) ${CONF_USER}

[ -z "$CONF_USER_PASSWORD" ] && export CONF_USER_PASSWORD=changeme
usermod --password $(echo "$CONF_USER_PASSWORD" | openssl passwd -1 -stdin) ${CONF_USER}
passwd -e ${CONF_USER}

# root passwd
[ -z "$CONF_ROOT_PASSWORD" ] && export CONF_ROOT_PASSWORD=starfive
usermod --password $(echo "$CONF_ROOT_PASSWORD" | openssl passwd -1 -stdin) root
passwd -e root

# enable services
systemctl enable NetworkManager.service
systemctl enable sshd.service
systemctl enable systemd-timesyncd.service

# ssh setup
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config || \
    echo "PermitRootLogin no" | tee -a /etc/ssh/sshd_config

# sudoers
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers

# add the add-on USB WiFi dongle's firmware
wget https://github.com/eswincomputing/eswin_6600u/raw/master/firmware/ECR6600U_transport.bin -O /lib/firmware/ECR6600U_transport.bin

# cleanup
rm -f /etc/machine-id
rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection
touch /etc/machine-id
sync

# vim:set ts=4 sts=4 sw=4 et:
