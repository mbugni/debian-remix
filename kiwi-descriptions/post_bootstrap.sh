#!/bin/bash

set -euxo pipefail

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Bootstrap image: [$kiwi_iname]-[$kiwi_iversion]..."
echo "Profiles: [$kiwi_profiles]"

#======================================
# Generate locales
#--------------------------------------
localedef -i en_US -c -f UTF-8 en_US.UTF-8
echo "C.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
if [ "$kiwi_language" != "en_US" ]; then
    livesys_locale="${kiwi_language}.UTF-8"
    livesys_language="${kiwi_language}"
	localedef -i ${livesys_language} -c -f UTF-8 ${livesys_locale}
    echo "${livesys_locale} UTF-8" >> /etc/locale.gen
    echo "LANG=${livesys_locale}" > /etc/default/locale
fi
echo "Generate locales..."
locale-gen
locale -a

#======================================
# Base system
#--------------------------------------
## Get packages info
apt-get update
## No interaction during install
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTED=none
## Setup base system
tasksel install standard
