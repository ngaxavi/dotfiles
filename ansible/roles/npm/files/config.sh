#!/bin/sh

mkdir /home/{{username}}/.npm-global
npm config set prefix '/home/{{username}}/.npm-global'


echo export PATH=~/.npm-global/bin:$PATH > /home/{{username}}/.profile
source /home/{{username}}/.profile
