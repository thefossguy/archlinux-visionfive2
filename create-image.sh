#!/usr/bin/env bash

export IMAGE_NAME=archlinux-$(date +%Y.%m.%d)-riscv64.img
export pkg_start="linux-starfive-visionfive2"
export pkg_end="5.15.0.arch1-1-riscv64.pkg.tar.zst"
export SPL_PART=lfs/0spl
export UBOOT_PART=lfs/1uboot

################################################################################
# satisfy pre-requisites before image creation
################################################################################

# exit if not run as root
if [ $EUID -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# handle kernel
./scripts/verify_file_and_checksum.sh "lfs/$pkg_start-$pkg_end" "7dfc44a4b0ea17a6350ac3ead7709040222859b9a54643fd56c5e6e446c45ddf1953d001da89f70153967d7e9ba09954f7d1de5be495a71324633abcaf8bb61b" || exit 1
./scripts/verify_file_and_checksum.sh "lfs/$pkg_start-headers-$pkg_end" "3f86f7dff13ea84036b20f46cbf41094779d6f91d698af32b27058dbdd8757cec3c3850c501d43358963be5c8c6e23a7bd57a048401a1bf8d06f612c52566f84" || exit 1

# make sure SPL_PART and UBOOT_PART are present and checksums match
./scripts/verify_file_and_checksum.sh "$SPL_PART" "6580149f59f1d0dfb5a6ea2f71f9261b2f0c7078467faa1bcdd1f015239dd98ce0c4b697d70644b01bb4286fea0c3133c3b1836e32d37a40eefd1ac30d36d581" || exit 1
./scripts/verify_file_and_checksum.sh "$UBOOT_PART" "8977525a17feb0214db5fe2ad5ff797a6e53ff40e765313f89bdddcc47ab2c81cc633e12d37d1eecfb02da762550d38bd56e0b3ab5eda94a40ecbcbac50d3a96" || exit 1


################################################################################
# image creation and related setup
################################################################################

# create image
[ -f "$IMAGE_NAME" ] && rm -v "$IMAGE_NAME"
truncate -s 2700M "$IMAGE_NAME"

# mount image to the loopback interface
LOOP_DEV=$(losetup -f -P --show "${IMAGE_NAME}")

# partition disk/image
cat << EOF | fdisk $LOOP_DEV
g
n
1
4096
8191
n
2
8192
16383
n
3
16384
+512M
n
4


t
1
198
t
2
197
t
3
1
t
4
20
w
EOF
sync

parted --script $LOOP_DEV \
    set 3 boot on \
    set 3 esp on \
    set 4 legacy_boot on
sync


# format partitions
dd status=progress conv=sync if="$SPL_PART" of=${LOOP_DEV}p1
dd status=progress conv=sync if="$UBOOT_PART" of=${LOOP_DEV}p2
mkfs.fat -F32 ${LOOP_DEV}p3
mkfs.ext4 -L archlinuxroot -F ${LOOP_DEV}p4

# mount partitions
mount ${LOOP_DEV}p4 /mnt || exit 1
mount --mkdir ${LOOP_DEV}p3 /mnt/boot || exit 1


################################################################################
# perform installation
################################################################################

# bootstrap packages
#pacstrap -C extra/pacman.conf /mnt archlinux-keyring aria2 bandwhich base base-devel bash bat bc bind btop choose cpio cron curl dash dhcpcd dnsmasq dog dua-cli dust exa fd findutils gcc git git-lfs htop hyperfine inetutils inxi iotop iperf iperf3 iputils kmod less libelf lsb-release lsof make man man-db man-pages mlocate nano neovim networkmanager nload opendoas openssh openssl pacman-contrib perl procs ripgrep rsync rustup skim smartmontools tar tealdeer tmux tre tree unrar unzip vim wget wireguard-tools wol xmlto xz zip zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting
bash scripts/install-packages.sh
if [ $? -ne 0 ]; then
    sync
    umount -R /mnt
    losetup -d $LOOP_DEV
    rm $IMAGE_NAME
    exit 1
fi
sync

# copy the vendor kernel
mkdir -p /mnt/chroot-data
cp -v lfs/*.pkg.tar.zst /mnt/chroot-data
cp -v scripts/kernel-installer.sh /mnt/chroot-data
sync

# now install the vendor kernel
arch-chroot /mnt bash /chroot-data/kernel-installer.sh 
if [ $? -ne 0 ]; then
    sync
    umount -R /mnt
    losetup -d $LOOP_DEV
    rm $IMAGE_NAME
    exit 1
fi

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# chroot setup
cp scripts/chroot-setup.sh /mnt/chroot-data/
arch-chroot /mnt bash /chroot-data/chroot-setup.sh
rm -rf /mnt/chroot-data

# boot stuff
cp -r boot/ /mnt/

# remove the zram
arch-chroot /mnt vim /etc/fstab


################################################################################
# wrap up
################################################################################

sync
umount -R /mnt
losetup -d $LOOP_DEV

# vim:set ts=4 sts=4 sw=4 et:
