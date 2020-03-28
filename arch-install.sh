#!/bin/bash

tell() {
  echo -e "\033[0;33m|-- ${*}\033[0m"
  "$@" || {
    echo -e "\033[0;31mFail !\033[0m" 1>&2 ;
    exit 1 ;
  }
}

explain() {
  echo -e "\033[0;34m${1}\033[0m"
}

success() {
  echo -e "\033[0;32m${1}\033[0m"
}

explain "Format Disk"
tell mkfs.ext4 -L arch-root /dev/sda1
tell mkswap -L swap /dev/sda2
tell mkfs.ext4 -L arch-data /dev/sda3
tell mkdir /mnt/data
tell mount /dev/sda1 /mnt
tell mount /dev/sda3 /mnt/data
tell swapon -L swap

explain "System Base - Install"
tell cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
tell grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist
tell pacman -Syu
tell pacman -S reflector

explain "Install base system"
tell pacstrap /mnt base base-devel linux-lts linux-firmware nano
tell pacman --root /mnt -S dhcpcd
tell pacman --root /mnt -S bash-completion wget git 
tell pacman --root /mnt -S intel-ucode
tell pacman --root /mnt -S wpa_supplicant
tell pacman --root /mnt -S wpa_supplicant netctl dialog

explain "Generate and verify fstab"
genfstab -Up /mnt > /mnt/etc/fstab
tell cat /mnt/etc/fstab

explain "Download Config for Arch chroot"
tell wget -P /mnt https://raw.githubusercontent.com/ngaxavi/dotfiles/master/arch-chroot.sh
tell chmod +x /mnt/base-setup-bios.sh

explain "Change to Arch chroot"
tell arch-chroot /mnt/