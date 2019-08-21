# Terastation-III-research

Tools for installing modern Debian on Terastation III (TS-WXL, TS-XL, TS-RXL) devices.


Everything here is experimental and will likely change greatly as we move forward. 

Currently the only device working acceptably is the 2-bay TS-WXL, sata is not yet working for the other models

These devices are more strict about their partition scheme than other devices, so far I’ve only been successful using the /boot created by buffalo’s firmware, even reformating it with the same fs (ext3) seems to cause uboot to regect it.

