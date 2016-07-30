#!/bin/sh

BASEDIR=$(dirname $0)
. $BASEDIR/inc/functions

explain "Install ansible"
  tell sudo pacman -Syu ansible --noconfirm --needed

explain "Change to ansible Installation"
  tell cd ansible

explain "Start Installation"
  tell ansible-playbook -i "local," install.yml
