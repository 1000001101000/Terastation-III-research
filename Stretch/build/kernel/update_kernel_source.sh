#!/bin/bash

kernel_ver="4.9"

##run as root/sudo
apt-get update
dpkg -l linux-source-$kernel_ver >/dev/null 2>&1
if [ $? -ne 0 ]; then
   apt-get install linux-source-$kernel_ver
else
  apt-get upgrade linux-source-$kernel_ver
fi

rm -r linux-source-$kernel_ver/
tar xf /usr/src/linux-source-$kernel_ver.tar.xz

user="$(ls -la . | grep -e ^d | head -n 1 | gawk '{print $3}')"
group="$(ls -la . | grep -e ^d | head -n 1 | gawk '{print $4}')"

chown -R $user:$group linux-source-$kernel_ver

##apply patches
