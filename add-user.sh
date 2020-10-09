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


if [ -z "$1" ]
then
    echo -e "Please enter the username";
    exit 1;
fi


explain "Add sudo"
tell pacman -S sudo fish --noconfirm --needed

explain "Create user"
tell useradd -m -g users -G wheel -s /usr/bin/fish "$1"
tell passwd "$1"
EDITOR=nano visudo
tell gpasswd -a "$1" wheel
tell gpasswd -a "$1" storage
tell gpasswd -a "$1" power
tell gpasswd -a "$1" lp
tell gpasswd -a "$1" network
tell gpasswd -a "$1" audio
tell gpasswd -a "$1" video
tell gpasswd -a "$1" optical
tell gpasswd -a "$1" games


explain "SSD config"
tell systemctl enable --now fstrim.timer

explain "Install and enable other services"
tell pacman -Sy ntp cronie acpid cups avahi dbus --noconfirm --needed
tell systemctl enable systemctl enable org.cups.cupsd.service
tell systemctl enable --now cronie
tell systemctl enable ntpd
tell systemctl enable acpid
tell systemctl enable avahi-daemon
tell systemctl enable --now systemd-timesyncd.service
tell date
tell hwclock -w

explain "Installation X and configuration"
tell pacman -S xorg-server xorg-xinit --needed
tell pacman -S xorg-drivers --needed
tell pacman -S xf86-input-synaptics --needed
tell localectl set-x11-keymap de pc105 de_nodeadkeys



