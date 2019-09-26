#!/bin/bash

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