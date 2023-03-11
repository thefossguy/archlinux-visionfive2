#!/usr/bin/env bash

source image.conf
if [ $? -ne 0 ]; then
    echo "ERROR: could not get configuration from image.conf"
    exit 1
fi

R_USER=$(who am i | awk '{print $1}')

################################################################################
# satisfy pre-requisites before image creation
################################################################################

# exit if not run as root
if [ $EUID -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# check if necessary pkgs are installed
INSTALL_PACKAGES=()
for PKG in {arch-install-scripts,bash,cloud-guest-utils,coreutils,dosfstools,e2fsprogs,ncurses,parted,perl,sed,shadow,sudo,util-linux,wget}; do
    IS_INSTALLED=$(pacman -Q | grep $PKG)
    if [ -z "$IS_INSTALLED" ]; then
        INSTALL_PACKAGES+=($PKG)
    fi
done
if [ ! -z "$INSTALL_PACKAGES" ]; then
    pacman -S "${INSTALL_PACKAGES[@]}"
fi

# make sure necessary files are present
./scripts/verify_file_and_checksum.sh "spl" || exit 1
./scripts/verify_file_and_checksum.sh "uboot" || exit 1
./scripts/verify_file_and_checksum.sh "kernel" || exit 1
./scripts/verify_file_and_checksum.sh "kheaders" || exit 1


################################################################################
# image creation and related setup
################################################################################

# create image
[ -f "$IMAGE_NAME" ] && rm -v "$IMAGE_NAME"
truncate -s 2300M "$IMAGE_NAME"

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
mkdir -p /mnt/var/cache/pacman/pkg
mount --bind /var/cache/pacman/pkg /mnt/var/cache/pacman/pkg || exit 1


################################################################################
# perform installation
################################################################################

# bootstrap packages
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
sync

# chroot setup
cp scripts/chroot-setup.sh /mnt/chroot-data/
arch-chroot /mnt bash /chroot-data/chroot-setup.sh
if [ $? -ne 0 ]; then
    sync
    umount -R /mnt
    losetup -d $LOOP_DEV
    rm $IMAGE_NAME
    exit 1
fi
rm -rf /mnt/chroot-data

# generate fstab
umount /mnt/var/cache/pacman/pkg
genfstab -U /mnt >> /mnt/etc/fstab

# boot stuff
cp -r boot/ /mnt/
sync


################################################################################
# wrap up
################################################################################

sync
umount -R /mnt
losetup -d $LOOP_DEV

# compress
[ -f "${IMAGE_NAME}.zst" ] && rm "${IMAGE_NAME}.zst"
zstd -9 -z $IMAGE_NAME

# generate checksums
echo -e '# SHA512SUMS' > CHECKSUMS
sha512sum $IMAGE_NAME "$IMAGE_NAME".zst >> CHECKSUMS
echo -e '\n# SHA512SUMS' >> CHECKSUMS
sha256sum $IMAGE_NAME "$IMAGE_NAME".zst >> CHECKSUMS
echo -e '\n# SHA512SUMS' >> CHECKSUMS
md5sum $IMAGE_NAME "$IMAGE_NAME".zst >> CHECKSUMS

# change final permissions
chown $R_USER:$R_USER -v $IMAGE_NAME "$IMAGE_NAME".zst CHECKSUMS


# vim:set ts=4 sts=4 sw=4 et:
