#!/usr/bin/env dash

# cleanup before installing more pkgs
rm -f /var/cache/pacman/pkg/*.*

# install the kernel
cd /chroot-data/
pacman --noconfirm -U *.pkg.tar.zst
if [ $? -eq 0 ]; then
    rm *.pkg.tar.zst
    sync
    exit 0
fi
exit 1
