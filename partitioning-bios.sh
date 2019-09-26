#!/bin/bash

tell() {
  echo -e "\033[0;33m|-- ${*}\033[0m"
  $* || {
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

if [ -z "$1" ]
then
      SWAP="8G"
      success "swap size is 8GB"
else
      SWAP=$1
      success "swap size is $1"
fi

explain "Create a single partition for LUKS"
tell parted -s /dev/sda mklabel msdos
tell parted -s /dev/sda mkpart primary 2048s 100%

explain "Create and mount the encrypted root filesystem"
tell cryptsetup luksFormat --type luks1 /dev/sda1
tell cryptsetup luksOpen /dev/sda1 lvm
tell pvcreate /dev/mapper/lvm
tell vgcreate arch /dev/mapper/lvm
tell lvcreate -L $SWAP arch -n swap
[ ! -z "$2" ] && tell lvcreate -L $2 arch -n data
tell lvcreate -l +100%FREE arch -n root
tell lvdisplay
tell mkswap -L swap /dev/mapper/arch-swap
tell mkfs.ext4 /dev/mapper/arch-root
[ ! -z "$2" ] &&  tell mkfs.ntfs /dev/mapper/arch-data
tell mount /dev/mapper/arch-root /mnt
tell swapon /dev/mapper/arch-swap

explain "Edit mirrorlist"
tell cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
tell grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

explain "Install base system"
tell pacstrap -i /mnt base base-devel net-tools wireless_tools dialog wpa_supplicant git grub ansible bash-completion wget

explain "Generate and verify fstab"
tell genfstab -U -p /mnt >> /mnt/etc/fstab
tell cat /mnt/etc/fstab

explain "Download Config for Arch chroot"
tell wget -P /mnt https://raw.githubusercontent.com/ngaxavi/dotfiles/master/base-setup-bios.sh
tell chmod +x /mnt/base-setup-bios.sh

explain "Change to Arch chroot"
tell arch-chroot /mnt /bin/bash

explain "Unmount and Reboot"
tell umount -R /mnt
tell reboot


