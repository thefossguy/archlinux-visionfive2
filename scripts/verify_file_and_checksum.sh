#!/usr/bin/env bash

LFS_REL_URL="https://github.com/thefossguy/archlinux-visionfive2/raw/master"
KERN_REL_URL="https://github.com/thefossguy/linux-starfive-visionfive2/releases/download/v2.10.4-3"
CHECKSUM_OK=1

if [ ! -z $1 ]; then
    if [ "$1" = "spl" ]; then
        FILE=$SPL_PART
        CHECKSUM="6580149f59f1d0dfb5a6ea2f71f9261b2f0c7078467faa1bcdd1f015239dd98ce0c4b697d70644b01bb4286fea0c3133c3b1836e32d37a40eefd1ac30d36d581"
        URL="$LFS_REL_URL/$FILE"
    elif [ "$1" = "uboot" ]; then
        FILE=$UBOOT_PART
        CHECKSUM="8977525a17feb0214db5fe2ad5ff797a6e53ff40e765313f89bdddcc47ab2c81cc633e12d37d1eecfb02da762550d38bd56e0b3ab5eda94a40ecbcbac50d3a96"
        URL="$LFS_REL_URL/$FILE"
    elif [ "$1" = "kernel" ]; then
        FILE=$KERNEL_PKG
        CHECKSUM="77b50818fbc9dab7c14604f3fea1b628bfb9b9f637a96aa318579fd72ab2ac8ad4c551d27716aba44ddc0d9c02869af41e7afac623a8b2451c5970bbbb06f49c"
        URL="$KERN_REL_URL/${FILE#lfs/}"
    elif [ "$1" = "kheaders" ]; then
        FILE=$KERNEL_HEADER_PKG
        CHECKSUM="cb3fb77831256de7b3d3694133b8ddbdec2572025ef17cd8f7a7897b6c5496dcb89bc2049dc9ebe6363a79a3ef255b654c1131de452ba6498aaea533c1c32ad0"
        URL="$KERN_REL_URL/${FILE#lfs/}"
    else
        echo "ERROR: invalid parameter"
        exit 1
    fi

else
    echo "ERROR: not enough parameters provided"
    exit 1
fi

verify_checksums() {
    echo "$CHECKSUM  $FILE" | /usr/bin/core_perl/shasum --check --status 2> /dev/null
    if [ $? -eq 0 ]; then
        CHECKSUM_OK=0
        exit 0
    else
        rm -v "$FILE"
        CHECKSUM_OK=1
        exit 1
    fi
}

download_file() {
    wget "$URL" -O "$FILE" > /dev/null || rm -v "$FILE"
}

while [ $CHECKSUM_OK -eq 1 ]; do
    if [ -f "$FILE" ]; then
        verify_checksums || (download_file || continue)
    else
        download_file || continue
    fi
done

# vim:set ts=4 sts=4 sw=4 et:
