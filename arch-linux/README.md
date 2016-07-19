## Build Your Arch Linux System (No Complete)

Arch Linux is a do-it-yourself Linux distro, It’s very popular among linux geeks and developers that like to really get at the nuts and bolts of a system. Arch give you the freedom to make any choice about the system. **It does not come with any pre-installed packages/drivers or graphical installer**, instead It uses a **command line installer**.
When you boot it up for the first time, you’ll be greeted with a command-line tool. It expects you to perform the entire installation from the command-line and install all the necessary program/driver by yourself and customize it the way you want it — by piecing together the components that you’d like to include on your system. 

Arch Linux is a really good way to learn what's going on inside a Linux box. You can learn a lot just from the installation process. I am going to walk through the base install, as well as several common post-install things like setting up networking, sound, mounts, X11 and video drivers, and adding users. I am not going to go in great detail on each step, so if you don't know how to do a certain step you may need to seek references elsewhere. 

I'll also show you some tips, tricks and tweaks on how you can change the way the GNOME desktop looks and feel to suit your own personal tastes, that is, take a plain-vanilla GNOME Shell and transform it into a desktop that you like. 

**WARNING**: There is a very **HIGH** chance you can destroy other operating systems or partition, if you don't do it right. **Please proceed with caution**. If you are new to Linux world I HIGHLY suggest you start off with a distro like Ubuntu or Mint Linux. Ubuntu is designed for people who want an off-the-shelf type system, where all of the choices are already made and the users are expected to sacrifice control for convenience.  

## Set the keyboard layout
```bash
root@arch ~ # loadkeys de-latin1
```

## Prepare the hard drives

Run this command:
```bash
root@arch ~ # cfdisk /dev/sda
```

- sda2 - swap **2GB**
- sda1 - root **250GB** (bootable)
- sda3 - data **230GB**  (data partition extended)



```bash
root@arch ~ # mkfs.ext4 -L arch /dev/sda1
root@arch ~ # mkswap -L swap /dev/sda2
root@arch ~ # mount /dev/sda1 /mnt
root@arch ~ # mkdir /mnt/data
root@arch ~ # mount /dev/sda3 /mnt/data
root@arch ~ # swapon -L swap
```


## Installing System Base

### System Base
Packages to be installed must be downloaded from mirror servers, which are defined in /etc/pacman.d/mirrorlist. On the live system, all mirrors are enabled, and sorted by their synchronization status and speed at the time the installation image was created.
The higher a mirror is placed in the list, the more priority it is given when downloading a package. You may want to edit the file accordingly, and move the geographically closest mirrors to the top of the list, although other criteria should be taken into account.

```bash
root@arch ~ # cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
root@arch ~ # grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist
```


```bash
root@arch ~ # pacstrap /mnt base base-devel wpa_supplicant
```

### Create fstab

```bash
root@arch ~ # genfstab -Lp /mnt > /mnt/etc/fstab
```

## Configuration the Installation

```bash
root@arch ~ # arch-chroot /mnt/
```

```bash
sh-4.3# echo myhost > /etc/hostname
sh-4.3# echo LANG=de_DE.UTF-8 > /etc/locale.conf
sh-4.3# echo LC_COLLATE=C >> /etc/locale.conf
sh-4.3# echo LANGUAGE=de_DE >> /etc/locale.conf
sh-4.3# echo KEYMAP=de-latin1 > /etc/vconsole.conf
sh-4.3# echo FONT=lat9w-16 >> /etc/vconsole.conf
sh-4.3# ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sh-4.3# nano /etc/locale.gen
```
Find # and remove it

```bash
#de_DE.UTF-8 UTF-8
#de_DE ISO-8859-1
#de_DE@euro ISO-8859-15
#en_US.UTF-8 UTF-8

sh-4.3# locale-gen
```
### Pacman Configuration

activate 32-bit library

```
/etc/pacman.conf

[multilib]
SigLevel = PackageRequired TrustedOnly
Include = /etc/pacman.d/mirrorlist

pacman -Sy
```
### Linux Kernel

```
mkinitcpio -p linux
```

```bash
sh-4.3# passwd  
```

```bash
sh-4.3# pacman -S grub bash-completion
sh-4.3# grub-install /dev/sda
sh-4.3# grub-mkconfig -o /boot/grub/grub.cfg
```

## Exit and Reboot the system
```
sh-4.3# exit
root@arch ~ # umount /dev/sda1
root@arch ~ # reboot

```


## Create a new user

```bash
root@myhostname ~ #  useradd -m -g users -s /bin/bash username
root@myhostname ~ #  passwd username
root@myhostname ~ #  EDITOR=nano visudo

```
Uncomment this line in this file(remove #):
```
#%wheel ALL=(ALL) ALL

root@myhostname ~ #  gpasswd -a username wheel
root@myhostname ~ #  gpasswd -a username storage
root@myhostname ~ #  gpasswd -a username power
root@myhostname ~ #  gpasswd -a username lp
root@myhostname ~ #  gpasswd -a username network
root@myhostname ~ #  gpasswd -a username audio
root@myhostname ~ #  gpasswd -a username video
root@myhostname ~ #  gpasswd -a username optical
root@myhostname ~ #  gpasswd -a username games
```

--

## Setup the system

##### enable network
```
root@myhostname ~ # ip addr
root@myhostname ~ # systemctl start dhcpcd@enp4s0.service
root@myhostname ~ # systemctl enable dhcpcd@enp4s0.service
```


##### Setup network, power manager, printer, DNS-SD framework, message bus system
```
root@myhostname ~ # pacman -Sy ntp cronie  acpid cups avahi dbus 
```

```
root@myhostname ~ # systemctl enable systemctl enable org.cups.cupsd.service
root@myhostname ~ # systemctl enable cronie
root@myhostname ~ # systemctl enable ntpd
root@myhostname ~ # systemctl enable acpid
root@myhostname ~ # systemctl enable avahi-daemon
```

#### Time Configuration
```
root@myhostname ~ # nano /etc/ntp.conf

replace the first line server 0.arch.pool.ntp.org wuth

server de.pool.ntp.org

root@myhostname ~ # ntpd -gq
root@myhostname ~ # hwclock -w

```

#### Install and configuration X
```
root@myhostname ~ # pacman -S xorg-server xorg-xinit xorg-utils xorg-server-utils
root@myhostname ~ # pacman -S xorg-drivers

```

#### Keyboard install
```
root@myhostname ~ # pacman -S xf86-input-synaptics
root@myhostname ~ # nano /etc/X11/xorg.conf.d/20-keyboard.conf 

Section "InputClass"
      Identifier "keyboard"
      MatchIsKeyboard "yes"
      Option "XkbLayout" "de"
      Option "XkbModel" "pc105"
      Option "XkbVariant" "nodeadkeys"
EndSection

or do
root@myhostname ~ # localectl set-x11-keymap de pc105 de_nodeadkeys

```

#### Mouse install
```
root@myhostname ~ # nano /etc/X11/xorg.conf.d/70-synaptics.conf

Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
        Option "TapButton1" "1"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "VertEdgeScroll" "on"
        Option "VertTwoFingerScroll" "on"
        Option "HorizEdgeScroll" "on"
        Option "HorizTwoFingerScroll" "on"
        Option "CircularScrolling" "on"
        Option "CircScrollTrigger" "2"
        Option "EmulateTwoFingerMinZ" "40"
        Option "EmulateTwoFingerMinW" "8"
        Option "CoastingSpeed" "0"
        Option "FingerLow" "30"
        Option "FingerHigh" "50"
        Option "MaxTapTime" "125"
EndSection
```

#### Alsa install

```bash
root@myhostname ~ # pacman -S alsa-utils alsa-plugins alsa-lib pulseaudio-alsa
root@myhostname ~ # pacman -S pavucontrol
```


#### Install GNOME Desktop Environment

```
root@myhostname ~ # pacman -S gnome gnome-extra
root@myhostname ~ # systemctl enable gdm
```


## Install Software

```
root@myhostname ~ # pacman -S firefox firefox-i18n-de chromium vlc docker
root@myhostname ~ # pacman -S flashplugin icedtea-web

```


### Reboot System
```
root@myhostname ~ # reboot
```


### Yaourt

```
$ sudo gedit /etc/pacman.conf
```

Add Yaourt repository:

```
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch
```
run:
```
$ pacman -Sy yaourt
```

## How to skip all Yaourt prompts on Arch Linux

[Yaourt](https://wiki.archlinux.org/index.php/yaourt) is probably the best tool to automatically download and install packages from the [Arch User Repository](https://aur.archlinux.org/), also known as AUR. It’s really powerful; however, by default, it prompts you a **LOT** for confirmations of different things, such as checking if you want to install something, if you want to edit the `PKGBUILD`, etc. As a result, Yaourt is pretty annoying if you’re used to the hands-free nature of most other package managers.

As it turns out, there is a file you can create called `~/.yaourtrc` that can change the behavior of Yaourt.

To turn off all of the prompts, type the following into a new file called `~/.yaourtrc`:

```
NOCONFIRM=1
BUILD_NOCONFIRM=1
EDITFILES=0
```

The first line will skip the messages confirming if you really want to install the package.

The second line will skip the messages asking you if you want to continue the build.

The third and last line will skip the messages asking if you want to edit the `PKGBUILD` files.

When you’re done doing this, Yaourt should now stop being a pain to use. Have fun with your hands-free installs!

--


### Upgrade Foreign packages

```
yaourt -Syua
```

--



Install AUR Packages

```
$ yaourt -S ttf-ms-fonts
$ yaourt -S paper-gtk-theme-git
$ yaourt -S ttf-mac-fonts
$ yaourt -S ttf-tahoma
$ yaourt -S jdk
$ yaourt -S intellij-idea-ultimate-edition
$ yaourt -S flattr-icon-theme
$ yaourt -S gnome-session-properties
```

--

### Install Network
```
$ sudo pacman -S networkmanager-dispatcher-ntpd networkmanager network-manager-applet
$ sudo systemctl enable NetworkManager
```


--



--

### Setup Albert 

#### install 
```bash
$ yaourt -S albert
```
Open Albert and setting it up


--

### Beautify Grub 2 Boot Loader by Installing Themes

By default, Arch Linux boot loader grub doesn’t use any theme. You can customize theme. Here’s a simple guide installing Grub2 themes (background, logos, fonts, scroll bar, etc).

**Download Archlinux theme from AUR:**  
Archxion: [grub2-theme-archxion](https://aur.archlinux.org/packages.php?ID=59370)  
Archlinux: [grub2-theme-archlinux](https://aur.archlinux.org/packages.php?ID=59643)

```
$ yaourt -S grub2-theme-archxion
$ yaourt -S grub2-theme-archlinux
```

**Edit your /etc/default/grub and change line:**  

```
$ sudo subl /etc/default/grub
```
<code>\#GRUB_THEME="/path/to/gfxtheme"  
to  
GRUB_THEME="/boot/grub/themes/Archxion/theme.txt"  
or  
GRUB_THEME="/boot/grub/themes/Archlinux/theme.txt"</code>

**The resolution the theme was designed to show best at 1024x768:**  
<code>GRUB_GFXMODE=auto  
to  
GRUB_GFXMODE=1024x768</code>  

**Update grub configuration:**  
<code>\# grub-mkconfig -o /boot/grub/grub.cfg</code>

--



### Arch Linux Pacman 

In Arch Linux softwares can be installed easily from the terminal by using pacman and you also use pacman to uninstall them( if you want to install softwares from the AUR, you can use packer). However, most linux softwares always come with many dependencies so if you just use the command pacman -R packagename to remove the application, there will always be a lot of orphan packages left around. The proper command to remove a linux software in Arch Linux should be:

```
 sudo pacman -Rns packagename 
``` 

This command will remove the package and its dependencies and all the settings of the application.

If you dont already know this tip, chances that there are still many orphan packages in your Arch linux box. To check if you have any orphan package, use the following command:

```
 sudo pacman -Qdt
```  

This command will display a list of orphan packages. To remove these packages, you can use the following command:

```
sudo pacman -Rns $(pacman -Qdtq) 
```

After that, all the orphan dependencies will be wiped out.

Note: In Arch Linux softwares will be updated very frequently so to keep your system clean, you should also use the command sudo pacman -Scc to clean cache and outdated packages. (But only do so after you make sure the new packages are working nicely. If they are not, you still need the old packages to downgrade)

