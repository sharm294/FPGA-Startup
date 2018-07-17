################################################################################
# This script takes two arguments: a FPGA serial number and a file name. It 
# writes the names of all containers that contain that serial number under the 
# user.fpga-serial key to the file.
#
# This script is called by program_fpga.sh
################################################################################

from pylxd import Client as lxdClient
import sys

def list_containers(serial, fileName):
	lxd = lxdClient()
	containers = lxd.containers.all()
	f = open(fileName, "w")
	
	for container in containers:
		try:
			fpgaSerialKey = container.config["user.fpga-serial"]
		except KeyError:
			continue #no FPGAs in this container
		
		for fpgaSerial in fpgaSerialKey.split(' '):
			if serial == fpgaSerial: #this container has this FPGA
				f.write(container.name)
				
	f.close()

if __name__ == "__main__":
	if len(sys.argv) != 3:
		sys.exit("Usage: python list_containers.py FPGA_SERIAL FILENAME")
		
	list_containers(sys.argv[1], sys.argv[2])
