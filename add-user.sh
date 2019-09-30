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
tell pacman -S sudo --noconfirm --needed

explain "Create user"
tell useradd -m -g users -s /bin/bash "$1"
tell passwd "$1"
EDITOR=nano visudo
tell gpasswd -a "$1" wheel

explain "Install keyboard"
tell pacman -S xf86-input-synaptics --noconfirm --needed
tell localectl set-x11-keymap de pc105 de_nodeadkeys

explain "Reboot"
tell reboot

