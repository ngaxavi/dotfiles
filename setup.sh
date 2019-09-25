#!/bin/sh

BASEDIR=$(dirname $0)
. $BASEDIR/inc/functions

explain "Install ansible"
  tell pacman -Syy python-passlib ansible --noconfirm --needed

explain "Install and Update the submodules"
  tell  git submodule init && git submodule update

explain "Change to ansible Installation"
  tell cd ansible

explain "Start Installation"
  tell ansible-playbook -i localhost playbook.yml
