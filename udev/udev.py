import os
import json
import sys
from pylxd import Client as lxdClient
from udev_common import jsonFile

def readd_usb(serialArg, M, m):
	os.system("touch /home/savi/udev_test3")
	lxd = lxdClient()
	containers = lxd.containers.all()

	major = M.zfill(3)
	minor = m.zfill(3)
	while True:
		try:
			fpgas = json.load(open(jsonFile))
			break
		except IOError:
			import write_json

	for container in containers:
		fpgaSerialKey = ""
		print("Container: " + container.name)
		try:
			fpgaSerialKey = container.config["user.fpga-serial"]
		except KeyError:
			print("  No FPGAs found in this container!")
			continue #no FPGAs in this container
		
		for fpgaSerial in fpgaSerialKey.split(' '):
			if(serialArg == fpgaSerial): #this container has been assigned this FPGA
				devices = container.devices
				print("Initial devices:")
				print(devices)
				
				for fpga in fpgas:
					if fpga['serial'] == serialArg:
						oldPath = fpga['path']
						break

				if os.path.exists(oldPath):
					break #no change in the enumeration of the USB device for any container
				#if 0:
				#    print("error")
				else:
					for device in devices:
						if "fpga" in device:
							if devices[device]['path'] == oldPath:
								fpgaMode = devices[device]['mode']
								fpgaType = devices[device]['type']
								del devices[device]
								fpgaNew = {}
								fpgaNew[u'path'] = u'/dev/bus/usb/' + major + '/' + minor
								fpgaNew[u'type'] = fpgaType
								fpgaNew[u'mode'] = fpgaMode
								devices[device] = fpgaNew
								oldMajor = oldPath.split('/')[-2]
								oldMinor = oldPath.split('/')[-1]
								oldLXDdevice = "/var/lib/lxd/devices/" + container.name + "/unix.dev-bus-usb-" + oldMajor + "-" + oldMinor
								if not os.path.exists(oldLXDdevice):
									nodeCmd = "mknod " + oldLXDdevice + " c 244 003"
									os.system(nodeCmd)
								container.devices = devices
								print("New devices")
								print(devices)
								container.save()
								for fpga in fpgas:
									if fpga['serial'] == serialArg:
										fpgas[fpgas.index(fpga)]['path'] = "/dev/bus/usb/" + major + "/" + minor

										with open(jsonFile, 'w') as outFile:
											json.dump(fpgas, outFile, indent=4)

if __name__ == "__main__":
	if len(sys.argv) != 4:
		sys.exit("Usage: python udev.py FPGA_SERIAL MAJOR MINOR")
		
	readd_usb(sys.argv[1], sys.argv[2], sys.argv[3])
