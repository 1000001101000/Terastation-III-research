#!/usr/bin/python3

import libmicon
import subprocess
import time
import sys

med_temp=27
high_temp=40

if len(sys.argv) > 1:
	debug=str(sys.argv[1])
else:
	debug=""

##try reading micon version from each port to determine the right one
for port in ["/dev/ttyS1","/dev/ttyS3"]:
	test = libmicon.micon_api(port)
	version = test.send_read_cmd(0x83)
	test.port.close()
	if version:
		break

while True:
	try:
		test = libmicon.micon_api(port)
		micon_temp=int.from_bytes(test.send_read_cmd(0x37),byteorder='big')
		##set speed based on thresholds
		fan_speed=1
		if micon_temp > med_temp:
			fan_speed=2
		if micon_temp > high_temp:
			fan_speed=3
		test.send_write_cmd(1,0x33,fan_speed)
		if debug == "debug":
			print("Fan Speed ",fan_speed," Temperature ",micon_temp,"C")
		test.port.close()
	except:
		print("Fan get/set failed, retrying")
		time.sleep(10)
		continue
	else:
		time.sleep(120)
quit()
