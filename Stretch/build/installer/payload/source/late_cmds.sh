##special stuff for micon
cp -r /source/micon_scripts "/target/usr/local/bin/"
cp /source/micon_scripts/*.service /target/etc/systemd/system/
cp /source/micon_scripts/micon_restart.sh /target/lib/systemd/system-shutdown/
chmod 755 /target/lib/systemd/system-shutdown/micon_restart.sh
cp /source/pack_kernel.sh "/target/usr/local/bin/"
chmod 755 /target/usr/local/bin/*.sh
##symlink to initramfs hook dir?

cp /source/linux-image.deb /target/root/


exit 0
