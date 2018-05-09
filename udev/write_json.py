import json #for json operations
import re #for ouput matching
import subprocess #for lsusb

from udev_common import jsonFile #json file name

#construct dictionary with FPGA information
re_device = re.compile("Bus\s+(?P<bus>\d+)\s+Device\s+(?P<device>\d+).+ID\s(?P<id>\w+:\w+)\s(?P<tag>.+)$", re.I)
re_serial = re.compile("\s*iSerial\s*\d (?P<serial>\w+)$", re.I)
df = subprocess.check_output("lsusb -v -d 0x0403: | grep -e ^Bus -e iSerial", shell=True)
devices = []
lastLine = None
for i in df.split('\n'):
    if i:
        info = re_device.match(i)
        if not info:
            dinfo = lastLine.groupdict()
            dinfo['path'] = '/dev/bus/usb/%s/%s' % (dinfo.pop('bus'), dinfo.pop('device'))
            dinfo['serial'] = re_serial.match(i).groupdict().pop('serial')
            devices.append(dinfo)
        else:
            lastLine = info

with open(jsonFile, 'w') as f:
    json.dump(devices, f, indent=4)
