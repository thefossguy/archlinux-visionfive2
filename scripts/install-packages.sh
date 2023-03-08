#!/usr/bin/env bash

################################################################################
# packages to be installed
################################################################################

PKGS_TO_INSTALL=(archlinux-keyring base bash bind btrfs-progs cronie curl dash dosfstools e2fsprogs exfatprogs findutils gcc git git-lfs htop iotop iperf iperf3 iputils less linux-firmware lm_sensors lsb-release lsof man man-db man-pages mlocate nano networkmanager opendoas openssh openssl pacman-contrib sudo tar tmux vim wget which xfsprogs xz zip zsh zstd)

# extra pkgs
#PKGS_TO_INSTALL+=(aria2 base-devel bat btop choose dog dua-cli dust exa fd hyperfine namcap neovim nload procs ripgrep rsync rustup skim tealdeer tre tree unrar unzip wget yt-dlp zsh-autosuggestions zsh-completions zsh-syntax-highlighting)


################################################################################
# install packages
################################################################################

pacstrap -C extra/pacman.conf /mnt "${PKGS_TO_INSTALL[@]}"

# vim:set ts=4 sts=4 sw=4 et:
