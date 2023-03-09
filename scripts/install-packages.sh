#!/usr/bin/env bash

################################################################################
# packages to be installed
################################################################################

PKGS_TO_INSTALL=(base man-db man-pages networkmanager openssh sudo vim)
[ -n "$CONF_ADD_PKGS_TO_INSTALL" ] && PKGS_TO_INSTALL+=(${CONF_ADD_PKGS_TO_INSTALL})

################################################################################
# install packages
################################################################################

pacstrap -C extra/pacman.conf /mnt "${PKGS_TO_INSTALL[@]}"

# vim:set ts=4 sts=4 sw=4 et:
