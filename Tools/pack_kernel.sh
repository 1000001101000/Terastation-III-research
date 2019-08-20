#!/bin/bash
##copy real initrd somewhere safe

#create an empty file the exact length needed to put the kernel at 0x02000000
##we're starting at 0x0090040 so that would be 23MB - 64b
##this is dec 24117184


cp /boot/uImage.buffalo /boot/uImage.buffalo.bak
devio 'wl 0xe3a01c0a,4' 'wl 0xe3811089,4' > /boot/tempkern
cat /boot/vmlinuz-$1 >> /boot/tempkern
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n  custom-$1 -d  /boot/tempkern /boot/uImage.buffalo
rm /boot/tempkern

dd if=/dev/null of=/boot/frontpad bs=1 seek=24117184

##create a tempfile which is the kernel padded to proper location
cat /boot/frontpad /boot/uImage.buffalo > /boot/padkern
rm /boot/frontpad

#padd the result to a predictable offset
dd if=/dev/null of=/boot/padkern bs=1M seek=30

cat /boot/padkern "$2" > /boot/hybrid.img
rm /boot/padkern

cp /boot/initrd.buffalo /boot/initrd.buffalo.bak
cp /boot/uImage.buffalo /boot/uImage.buffalo.bak

mkimage -A arm -O linux -T ramdisk -C gzip -a 0x0 -e 0x0 -n hybrid-$1 -d /boot/hybrid.img /boot/initrd.buffalo

rm /boot/hybrid.img
