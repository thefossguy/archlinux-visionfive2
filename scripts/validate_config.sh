#!/usr/bin/env bash

checkvar() {
    builder='[ -z "$'
    builder+=$1
    builder+='" ] && found=1'
    eval "$builder"
    if [ $? -eq 0 ]; then
       echo "ERROR: var $1 undefined or empty"
       exit 1
    fi
}

checkvar CONF_TIMEZONE || exit $?
checkvar CONF_LOCALE || exit $?
checkvar CONF_HOSTNAME || exit $?
checkvar CONF_USER || exit $?
checkvar CONF_USER_PASSWORD || exit $?
checkvar CONF_GROUPS || exit $?
checkvar CONF_PKGS_TO_INSTALL || exit $?
checkvar LFS_REL_URL || exit $?
checkvar KERN_REL_URL || exit $?
checkvar SPL_PART || exit $?
checkvar SPL_PART_SHA512SUM || exit $?
checkvar UBOOT_PART || exit $?
checkvar UBOOT_PART_SHA512SUM || exit $?
checkvar KERNEL_PKG || exit $?
checkvar KERNEL_PKG_SHA512SUM || exit $?
checkvar KERNEL_HEADER_PKG || exit $?
checkvar KERNEL_HEADER_PKG_SHA512SUM || exit $?
checkvar IMAGE_NAME || exit $?
