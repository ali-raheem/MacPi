# PiSec
Create macsec encrypted ethernet links automatically and transparently with minimal interaction

## Running

1. Clone this repository
2. Start master instance
3. Start slave instance
4. Confirm hash match on both devices

```
git clone git@github.com:ali-raheem/PiSec.git --depth=1
master# bash sync.sh -m
slave# bash sync.sh
```
If you don't want to run the script in a root shell use ```sudo```.

You need to confirm the public key hashes on both devices with ```y``` when promited.

Running the script again will prompt you to reuse the last config or start fresh. Start fresh if there was an error previously.

They link will then automatically be set up.

## Dependencies

* macsec (Kernel >= 4.6)
* Flask
* openssl

## Todo

* use dhcpd?
* use iptables to forward/NAT traffic to allow bridging?
* IPv6?
* Use SPI screen and buttons on raspberry pi

## Notes

* For raspberry pi (atleast) you will need to compile the macsec module. It's [easy](https://www.raspberrypi.org/documentation/linux/kernel/configuring.md), just make sure to enable macsec as a module in .config (uncomment `macsec m`).
* There will be a performance hit, on my ancient laptop 950 mbps without macsec 850 mbps with macsec. On RPi1 60 mbps to 12 mbps testing with iperf3.
* Currently using brainpoolP512t1, maybe there is something better? Should be hashing params file? Or just using a named curve?
