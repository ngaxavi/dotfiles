#!/bin/bash

# create a single partition for LUKS
parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 2048s 100%

# Create and mount the encrypted root filesystem
cryptsetup luksFormat --type luks1 /dev/sda1
cryptsetup luksOpen /dev/sda1 lvm
pvcreate /dev/mapper/lvm
vgcreate arch /dev/mapper/lvm
lvcreate -L 8G arch -n swap
lvcreate -L 5G arch -n data
lvcreate -l +100%FREE arch -n root
lvdisplay
mkswap -L swap /dev/mapper/arch-swap
mkfs.ext4 /dev/mapper/arch-root
mkfs.ntfs /dev/mapper/arch-data
mount /dev/mapper/arch-root /mnt
swapon /dev/mapper/arch-swap

# Edit mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

# Install base system
pacstrap -i /mnt base base-devel net-tools wireless_tools dialog wpa_supplicant git grub ansible bash-completion

# Generate and verify fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Change root into the base install and perform base configuration tasks.
arch-chroot /mnt /bin/bash
export LANG=de_DE.UTF-8
echo $LANG UTF-8 >> /etc/locale.gen
echo de_DE ISO-8859-1 >> /etc/locale.gen
echo de_DE@euro ISO-8859-15 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=$LANG > /etc/locale.conf
echo LC_TIME=$LANG >> /etc/locale.conf
echo LC_COLLATE=C >> /etc/locale.conf
echo LANGUAGE=de_DE >> /etc/locale.conf
echo KEYMAP=de-latin1 > /etc/vconsole.conf
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
echo dev-monster > /etc/hostname
systemctl enable dhcpcd.service
passwd

# Set your mkinitcpio encrypt/lvm2 hooks and rebuild.
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 resume filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

#  Add a keyfile to decrypt the root volume and properly set the hooks
dd bs=512 count=8 if=/dev/urandom of=/crypto_keyfile.bin
cryptsetup luksAddKey /dev/sda1 /crypto_keyfile.bin
chmod 000 /crypto_keyfile.bin
sed -i 's/^FILES=.*/FILES=(\/crypto_keyfile.bin)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Configure GRUB
echo GRUB_ENABLE_CRYPTODISK=y >> /etc/default/grub

# BIOS mode - set the UUID of the encrypted root device
ROOTUUID=$(blkid /dev/sda1 | awk '{print $2}' | cut -d '"' -f2)
sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID="$ROOTUUID":lvm:allow-discards resume=\/dev\/mapper\/arch-swap\"/" /etc/default/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
chmod -R g-rwx,o-rwx /boot

# Cleanup and reboot
exit
umount -R /mnt
reboot


