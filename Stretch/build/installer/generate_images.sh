##requires uboot-tools, gzip, faketime, rsync, wget, cpio, libarchive-cpio-perl
## making this smaller via a PPA sounds like fun.
distro="stretch"

tools_dir="../../../Tools/"

cd debian-files
if [ -d "tmp" ]; then
   rm -r "tmp/"
fi

wget -N "http://ftp.nl.debian.org/debian/dists/$distro/main/installer-armel/current/images/kirkwood/netboot/initrd.gz"

mkdir tmp
cp ../../../uImage.buffalo .
if [ $? -ne 0 ]; then
        echo "uImage missing, quitting"
        exit
fi

cp -v "$(ls -rt ../../../linux-image*.deb | grep -v dbg | tail -n 1)" linux-image.deb
if [ $? -ne 0 ]; then
        echo "kernel package missing, quitting"
        exit
fi

dpkg --extract linux-image.deb tmp/
if [ $? -ne 0 ]; then
        echo "failed to unpack kernel, quitting"
        exit
fi
cd ..
rm -r payload/lib/modules/*
rsync -rtWhmv --include "*/" \
--include="*/drivers/md/*" \
--include="m25p80.ko" \
--include="spi_nor.ko" \
--include="ehci_orion.ko" \
--include="ehci_hcd.ko" \
--include="sg.ko" \
--include="marvell.ko" \
--include="usbcore.ko" \
--include="usb_common.ko" \
--include="mvmdio.ko" \
--include="mv643xx_eth.ko" \
--include="of_mdio.ko" \
--include="fixed_phy.ko" \
--include="libphy.ko" \
--include="ip_tables.ko" \
--include="x_tables.ko" \
--include="ipv6.ko" \
--include="autofs4.ko" \
--include="ext4.ko" \
--include="msdos.ko" \
--include="fat.ko" \
--include="vfat.ko" \
--include="xfs.ko" \
--include="crc16.ko" \
--include="jbd2.ko" \
--include="fscrypto.ko" \
--include="ecb.ko" \
--include="mbcache.ko" \
--include="raid10.ko" \
--include="raid456.ko" \
--include="libcrc32c.ko" \
--include="crc32c_generic.ko" \
--include="async_raid6_recov.ko" \
--include="async_memcpy.ko" \
--include="async_pq.ko" \
--include="async_xor.ko" \
--include="xor.ko" \
--include="async_tx.ko" \
--include="raid6_pq.ko" \
--include="raid0.ko" \
--include="multipath.ko" \
--include="linear.ko" \
--include="raid1.ko" \
--include="md_mod.ko" \
--include="sd_mod.ko" \
--include="sata_mv.ko" \
--include="libata.ko" \
--include="scsi_mod.ko" \
--exclude="*" debian-files/tmp/lib/ payload/lib/
if [ $? -ne 0 ]; then
        echo "failed to copy module files, quitting"
        exit
fi

cp debian-files/linux-image.deb payload/source/
if [ $? -ne 0 ]; then
        echo "failed to copy kernel package, quitting"
        exit
fi

cp -v $tools_dir/*.sh payload/source/
if [ $? -ne 0 ]; then
        echo "failed to copy tools, quitting"
        exit
fi

cp -vrp $tools_dir/micon_scripts payload/source/
if [ $? -ne 0 ]; then
        echo "failed to copy micon tools, quitting"
        exit
fi

cp -v $tools_dir/*.db payload/source/
if [ $? -ne 0 ]; then
        echo "failed to copy device db, quitting"
        exit
fi

cp debian-files/uImage.buffalo .
if [ $? -ne 0 ]; then
        echo "failed to retrieve uImage.buffalo, quitting"
        exit
fi

zcat debian-files/initrd.gz | cpio-filter --exclude "lib/modules/*" > initrd
if [ $? -ne 0 ]; then
        echo "failed to unpack initrd, quitting"
        exit
fi

cd payload

find . | cpio -v -H newc -o -A -F ../initrd
if [ $? -ne 0 ]; then
        echo "failed to patch initrd.gz, quitting"
        exit
fi
cd ..
gzip initrd
if [ $? -ne 0 ]; then
        echo "failed to pack initrd, quitting"
        exit
fi

##pack initrd+uImage together to get around stock uboot limitation
dd if=/dev/null of=frontpad bs=1 seek=24117184
cat frontpad uImage.buffalo > padkern
rm frontpad
dd if=/dev/null of=padkern bs=1M seek=30
cat padkern initrd.gz > installer-initrd.img
rm padkern
faketime '2018-01-01 01:01:01' /bin/bash -c "mkimage -A arm -O linux -T ramdisk -C gzip -a 0x0 -e 0x0 -n installer-initrd -d installer-initrd.img output/initrd.buffalo"
if [ $? -ne 0 ]; then
        echo "failed to create initrd.buffalo, quitting"
        exit
fi
mv uImage.buffalo output/

zip output/$distro-installer-files.zip output/*.buffalo

rm installer-initrd.img
rm initrd.gz
rm payload/source/*.deb

