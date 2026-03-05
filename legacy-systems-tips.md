# Legacy systems tips

## Purpose
This guide describes some tricks for legacy systems.

## Disable AppArmor and SELinux
Stop the AppArmor service:
```shell
sudo systemctl stop apparmor
```

Disable AppArmor from starting at boot:
```shell
sudo systemctl disable apparmor
```

Remove the AppArmor package and its dependencies:
```shell
sudo apt remove --purge apparmor
```

Disable SELinux by editing the `SELINUX` variable in the `/etc/selinux/config` file:
```
SELINUX=disabled
```

Edit the `/etc/default/grub` config file and append the following at the end of the `GRUB_CMDLINE_LINUX_DEFAULT` variable:
```
GRUB_CMDLINE_LINUX_DEFAULT="... apparmor=0 selinux=0"
```

Update the GRUB boot menu:
```shell
sudo update-grub
```

## Install SeaMonkey browser via APT
Install the [SeaMonkey browser](https://www.seamonkey-project.org/) running the following script:
```shell
sudo install-seamonkey
```

## Install Basilisk browser via download
Install the [Basilisk browser](https://www.basilisk-browser.org/) running the following script:
```shell
sudo install-basilisk
```

## Install legacy Broadcom firmare

#### Install the manual extractor
```shell
sudo apt update
sudo apt install b43-fwcutter
```

#### Download the firmware
```shell
wget https://sources.openwrt.org
```

#### Extract the firmware
```shell
tar xfvj broadcom-wl-5.100.138.tar.bz2
sudo b43-fwcutter -w /lib/firmware broadcom-wl-5.100.138/linux/wl_apsta.o
```

#### Load the kernel module
```shell
sudo modprobe b43
```

## Use an alternative Window Manager for TDE
You can follow the ["use another window manager"](https://wiki.trinitydesktop.org/Tips_And_Tricks#Use_another_window_manager_with_TDE) guide.

Assume you want to use [Openbox](https://openbox.org/) instead of the default TWin.
First, install Openbox:
```shell
sudo apt update

sudo apt install openbox
```

To set it permanently, edit the `$HOME/.trinity/share/config/twinrc` file and add the following:
```ini
[ThirdPartyWM]
WMExecutable=openbox
# Set this to pass additional arguments
# WMAdditionalArguments=
```