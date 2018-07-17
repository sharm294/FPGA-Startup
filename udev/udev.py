################################################################################
# This script is called by udev when a FPGA USB is reinserted. It updates the 
# path to the FPGA in any containers that already have access to it.
#
# To run it manually, make sure the current path of the FPGA in the container 
# matches the entry in the udev.json database file.
################################################################################

import os #for path checking and shell commands
import json #for json parsing
import sys #for command line arguments
from pylxd import Client as lxdClient
from udev_common import jsonFile #the filename

def update_path(container, serialArg, fpgas, major, minor):
	#get the old path for this FPGA from the database
	for fpga in fpgas:
		if fpga['serial'] == serialArg:
			oldPath = fpga['path']
			break

	devices = container.devices
	for device in devices:
		if "fpga" in device and devices[device]['path'] == oldPath:
			
			#save the mode and type from the current device entry
			fpgaMode = devices[device]['mode']
			fpgaType = devices[device]['type']
			del devices[device]

			#create the new entry
			fpgaNew = {}
			fpgaNew[u'path'] = u'/dev/bus/usb/' + major + '/' + minor
			fpgaNew[u'type'] = fpgaType
			fpgaNew[u'mode'] = fpgaMode
			devices[device] = fpgaNew
			
			#LXC has this issue where you sometimes can't delete a device if 
			#it doesn't exist. This creates a dummy device in case it doesn't 
			#exist for some reason.
			oldMajor = oldPath.split('/')[-2]
			oldMinor = oldPath.split('/')[-1]
			oldLXDdevice = "/var/lib/lxd/devices/" + container.name + \
				"/unix.dev-bus-usb-" + oldMajor + "-" + oldMinor
			if not os.path.exists(oldLXDdevice):
				nodeCmd = "mknod " + oldLXDdevice + " c 244 003"
				os.system(nodeCmd)

			#save the config and update the database
			container.devices = devices
			container.save()
			for fpga in fpgas:
				if fpga['serial'] == serialArg:
					fpgas[fpgas.index(fpga)]['path'] = "/dev/bus/usb/" + \
						major + "/" + minor

					with open(jsonFile, 'w') as outFile:
						json.dump(fpgas, outFile, indent=4)

def readd_usb(serialArg, M, m):
	lxd = lxdClient()
	containers = lxd.containers.all()
	
	#zero extend major and minor numbers
	major = M.zfill(3)
	minor = m.zfill(3)
	
	#create the database if needed and open it
	if os.path.exists(jsonFile):
		fpgas = json.load(open(jsonFile))
	else:
		import write_json
		fpgas = json.load(open(jsonFile))

	for container in containers:
		fpgaSerialKey = ""
		try:
			fpgaSerialKey = container.config["user.fpga-serial"]
		except KeyError:
			continue #no FPGAs in this container
		
		for fpgaSerial in fpgaSerialKey.split(' '):
			if(serialArg == fpgaSerial): #this container has this FPGA				
				update_path(container, serialArg, fpgas, major, minor)

if __name__ == "__main__":
	if len(sys.argv) != 4:
		sys.exit("Usage: python udev.py FPGA_SERIAL MAJOR MINOR")
		
	readd_usb(sys.argv[1], sys.argv[2], sys.argv[3])
