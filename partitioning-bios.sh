#!/bin/bash

if [ -z "$1" ]
then
      SWAP="8G"
else
      SWAP=$1
fi

# create a single partition for LUKS
parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 2048s 100%

# Create and mount the encrypted root filesystem
cryptsetup luksFormat --type luks1 /dev/sda1
cryptsetup luksOpen /dev/sda1 lvm
pvcreate /dev/mapper/lvm
vgcreate arch /dev/mapper/lvm
lvcreate -L $SWAP arch -n swap
[ ! -z "$2" ] && lvcreate -L $2 arch -n data
lvcreate -l +100%FREE arch -n root
lvdisplay
mkswap -L swap /dev/mapper/arch-swap
mkfs.ext4 /dev/mapper/arch-root
[ ! -z "$2" ] &&  mkfs.ntfs /dev/mapper/arch-data
mount /dev/mapper/arch-root /mnt
swapon /dev/mapper/arch-swap

# Edit mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

# Install base system
pacstrap -i /mnt base base-devel net-tools wireless_tools dialog wpa_supplicant git grub ansible bash-completion wget

# Generate and verify fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

wget -P /mnt https://raw.githubusercontent.com/ngaxavi/dotfiles/master/base-setup-bios.sh
chmod +x /mnt/base-setup-bios.sh

arch-chroot /mnt /bin/bash

# reboot
umount -R /mnt
reboot


