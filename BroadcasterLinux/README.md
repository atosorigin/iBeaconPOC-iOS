Commands
------------
- Stop broadcasting: 
> sudo ./ibeacon -z
- Start broadcasting (Max = 1, Min = 0): 
> sudo ./ibeacon -u 723C0A0F-D506-4175-8BB7-229A21BE470B -M 0 -m 1

Change the "-m" parameter, where 1 = Kitchen, 2 = Reception and 3 = Desks


Information
------------

This uses the [linx iBeacon script from GitHub][SOURCEGITHUB]

Full list of commands below below:

How to use it
-------------

    Usage: sudo ibeacon [-u|--uuid=UUID or `random' (default=Beacon Toolkit app)]
                        [-M|--major=major (0-65535, default=0)]
                        [-m|--minor=minor (0-65535, default=0)]
                        [-p|--power=power (0-255, default=200)]
                        [-d|--device=BLE device to use (default=hci0)]
                        [-z|--down]
                        [-v|--verbose]
                        [-n|--simulate (implies -v)]
                        [-h|--help]

This script must be run with `root` privileges in order to configure Bluetooth adapters.  It is most convenient to run it using `sudo.`

[SOURCEGITHUB]: https://github.com/dburr/linux-ibeacon "Linux iBeacon"


