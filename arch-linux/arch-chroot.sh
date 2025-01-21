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

explain "Configuration System"
echo worklabs > /etc/hostname
tell export LANG=de_DE.UTF-8
echo $LANG UTF-8 >> /etc/locale.gen
echo de_DE ISO-8859-1 >> /etc/locale.gen
echo de_DE@euro ISO-8859-15 >> /etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
tell locale-gen
echo LANG=$LANG > /etc/locale.conf
echo LC_TIME=$LANG >> /etc/locale.conf
echo LC_COLLATE=C >> /etc/locale.conf
echo LANGUAGE=de_DE >> /etc/locale.conf
echo KEYMAP=de-latin1-nodeadkeys > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf
tell ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
echo -e "[multilib] \nSigLevel = PackageRequired TrustedOnly \nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
tell pacman -Sy
tell mkinitcpio -p linux-lts
tell passwd

explain "Configure GRUB"
tell pacman -S grub
tell grub-install /dev/sda
tell grub-mkconfig -o /boot/grub/grub.cfg

explain "Download user config"
tell wget -P /mnt https://raw.githubusercontent.com/ngaxavi/dotfiles/master/add-user.sh
tell chmod +x /mnt/add-user.sh

explain "Rest command"
echo "unmount /dev/sda1"
echo "unmount /dev/sda3"
echo "reboot"

explain "Exit"
tell exit