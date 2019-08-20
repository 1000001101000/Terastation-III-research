##special stuff for micon
systemctl enable micon_boot.service
systemctl enable micon_lcd.service

dpkg -i /root/linux-image.deb
rm /root/linux-image.deb
exit 0
