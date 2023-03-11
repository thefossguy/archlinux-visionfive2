#!/usr/bin/env bash

################################################################################
# install packages
################################################################################

PKGS_TO_INSTALL=(`echo "${CONF_PKGS_TO_INSTALL}"`)
pacstrap -C extra/pacman.conf /mnt "${PKGS_TO_INSTALL[@]}"

# vim:set ts=4 sts=4 sw=4 et:
