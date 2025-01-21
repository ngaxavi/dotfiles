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

explain "Install KDE Desktop"
tell sudo pacman -S plasma-meta sddm sddm-kcm --noconfirm --needed
tell sudo systemctl enable sddm.service

explain "Starter for Plasma X11"
echo "exec startplasma-x11" > ~/.xinitrc

explain "Installation"
tell sudo pacman -S konsole dolphin firefox firefox-i18n-de kate --noconfirm --needed

explain "Installation Network"
tell sudo pacman -S networkmanager plasma-nm
tell sudo systemctl stop dhcpcd
tell sudo systemctl disable dhcpcd
tell sudo systemctl enable NetworkManager
tell sudo systemctl start NetworkManager

explain "Reboot System"
tell sudo reboot

explain "Installation of some utils"
tell sudo pacman -S ark kinfocenter gwenview gimp spectacle okular vlc redshift kfind ktorrent --noconfirm --needed
yay -S plasma5-applets-redshift-control-git
