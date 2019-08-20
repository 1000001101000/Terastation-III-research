#!/bin/bash
## download from https://releases.linaro.org/components/toolchain/binaries/
prefix="/usr/local/bin/distcc/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"

kernel_ver="4.9"
rm *.deb
rm *.changes

cd linux-source-$kernel_ver
cp  ../custom-config-$kernel_ver .config
make oldconfig ARCH=arm
make -j$(nproc) ARCH=arm KBUILD_DEBARCH=armel CROSS_COMPILE="$prefix" bindeb-pkg

cd ..
devio 'wl 0xe3a01c0a,4' 'wl 0xe3811089,4' > machtype
cat machtype linux-source-$kernel_ver/arch/arm/boot/zImage > katkern
rm machtype
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n  custom-$kernel_ver -d  katkern uImage.buffalo
rm katkern

exit 0


