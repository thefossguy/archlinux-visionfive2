#!/usr/bin/env bash


if [ ! -z $1 ]; then
    if [ "$1" = "kernel" ]; then
        FILE=$KERNEL_PKG
        CHECKSUM=$KERNEL_PKG_SHA512SUM
        URL="$KERN_REL_URL/${FILE#lfs/}"
    elif [ "$1" = "kheaders" ]; then
        FILE=$KERNEL_HEADER_PKG
        CHECKSUM=$KERNEL_HEADER_PKG_SHA512SUM
        URL="$KERN_REL_URL/${FILE#lfs/}"
    else
        echo "ERROR: invalid parameter"
        exit 1
    fi

else
    echo "ERROR: not enough parameters provided"
    exit 1
fi

CHECKSUM_OK=1
verify_checksums() {
    echo "$CHECKSUM  $FILE" | /usr/bin/core_perl/shasum --check --status 2> /dev/null
    if [ $? -eq 0 ]; then
        CHECKSUM_OK=0
        exit 0
    else
        echo "mismatch checksum $FILE $CHECKSUM"
        rm -v "$FILE"
        CHECKSUM_OK=1
        exit 1
    fi
}

download_file() {
    wget "$URL" -O "$FILE" > /dev/null || rm -v "$FILE"
}

RETRY_COUNT=3
while [ $CHECKSUM_OK -eq 1 ]; do
    [ $RETRY_COUNT -eq 0 ] && exit 1
    ((RETRY_COUNT=$RETRY_COUNT-1))
    if [ -f "$FILE" ]; then
        verify_checksums || (download_file || continue)
    else
        download_file || continue
    fi
done

# vim:set ts=4 sts=4 sw=4 et:
