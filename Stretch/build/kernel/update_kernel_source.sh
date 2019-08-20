#!/bin/bash

kernel_ver="4.9"

##run as root/sudo
apt-get update
apt-get install linux-source-$kernel_ver

rm -r linux-source-$kernel_ver/
tar xf /usr/src/linux-source-$kernel_ver.tar.xz

user="$(ls -la . | grep -e ^d | head -n 1 | gawk '{print $3}')"
group="$(ls -la . | grep -e ^d | head -n 1 | gawk '{print $4}')"

cd linux-source-$kernel_ver
for patch in $(ls ../patches)
do
  patch -p1 < ../patches/$patch
done
cd ..

chown -R $user:$group linux-source-$kernel_ver
