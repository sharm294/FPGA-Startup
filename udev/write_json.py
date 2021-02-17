################################################################################
# This script writes a json file that has information about the FPGAs connected 
# via USB on this machine.
################################################################################

import json #for json operations
import re #for ouput matching
import subprocess #for lsusb
import os # for file operations

from udev_common import jsonFile #json file name

#this command outputs the bus path, vendor information and ID on one line,
#and the FPGA's serial number on the next line. I match against these using 
#regex expressions.
def write_json():
    df = subprocess.check_output("lsusb -v -d 0x0403: | \
        grep -e ^Bus -e iSerial", shell=True)

    #construct dictionary with FPGA information
    re_device = re.compile(r"Bus\s+(?P<bus>\d+)\s+Device\s+(?P<device>\d+).+ID\s(?P<id>\w+:\w+)\s(?P<tag>.+)$", re.I)
    re_serial = re.compile(r"\s*iSerial\s*\d (?P<serial>\w+)$", re.I)

    devices = []
    lastLine = None
    try:
        terms = df.split('\n')
    except TypeError:
        terms = df.decode().split('\n')
    for i in terms:
        if i:
            info = re_device.match(i)
            if not info:
                dinfo = lastLine.groupdict()
                dinfo['path'] = '/dev/bus/usb/%s/%s' % (dinfo.pop('bus'), dinfo.pop('device'))
                dinfo['serial'] = re_serial.match(i).groupdict().pop('serial')
                devices.append(dinfo)
            else:
                lastLine = info

    dirname = os.path.dirname(jsonFile)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    with open(jsonFile, 'w') as f:
        json.dump(devices, f, indent=4)

if __name__ == "__main__":
    write_json()
