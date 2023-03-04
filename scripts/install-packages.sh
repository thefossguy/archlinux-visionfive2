#!/usr/bin/env bash

################################################################################
# packages to be installed
################################################################################

PKGS_TO_INSTALL=(archlinux-keyring base base-devel bash bind btrfs-progs cron curl dash dhcpcd dosfstools e2fsprogs exfatprogs findutils gcc git git-lfs htop inxi iotop iperf iperf3 iputils less linux-firmware lm_sensors lsb-release lsof man man-db man-pages mlocate namcap nano neovim networkmanager opendoas openssh openssl pacman-contrib rsync sudo tar tmux unrar unzip vim wget xfsprogs xz zip zsh zstd)


# extra pkgs
#PKGS_TO_INSTALL+=(aria2 bat btop choose dog dua-cli dust exa fd hyperfine nload procs ripgrep rustup skim tealdeer tre tree wget yt-dlp zsh-autosuggestions zsh-completions zsh-syntax-highlighting)


################################################################################
# install packages
################################################################################
echo "Running sudo for pacstrap"
sudo pacstrap -C extra/pacman.conf /mnt "${PKGS_TO_INSTALL[@]}" || exit 1