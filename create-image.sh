#!/usr/bin/env bash

CONFIG="image.conf"

show_usage() {
    echo "Create Arch Linux image for the RISC-V StarFive VisionFive 2 single board computer\n

USAGE:
    create-image.sh [ -h | CONFIG_FILE]

ARGS:
    <FILE>    Configuration file

OPTIONS:
    -h, --help        Print this help message."
}


################################################################################
# satisfy pre-requisites before image creation
################################################################################

# Parse CLI arguments
if [ $# -ne 0 ]; then
    [ $# -gt 1 ] && (>&2 echo "error: too many arguments" && show_usage && exit 1)
    [ $1 == "-h" ] && (show_usage && exit 0)
    [ $1 == "--help" ] && (show_usage && exit 0)
    if [ -f "$1" ]; then
        CONFIG=$1
    else
        >&2 echo "error: config file '$1' not found" && exit 1
    fi
fi

# Read and validate configuration
source "$CONFIG"
[ $? -ne 0 ] && { >&2 echo "ERROR: could not read configuration from '$CONF'"; exit 1; }
scripts/validate_config.sh || { >&2 echo "ERROR: invalid configuration"; exit 1; }


# exit if not run as root
R_USER=$(who am i | awk '{print $1}')
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

+512M
n
2


t
1
1
t
2
20
w
EOF
sync

parted --script $LOOP_DEV \
    set 1 boot on \
    set 1 esp on \
    set 2 legacy_boot on
sync


# format partitions
mkfs.fat -F32 ${LOOP_DEV}p1
mkfs.ext4 -L archlinuxroot -F ${LOOP_DEV}p2

# mount partitions
mount ${LOOP_DEV}p2 /mnt || exit 1
mount --mkdir ${LOOP_DEV}p1 /mnt/boot || exit 1
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
