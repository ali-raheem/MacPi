# PiSec
Create macsec encrypted ethernet links automatically and transparently with minimal interaction

## Running

On the first device called the "master" run `./sync.sh -m`, when prompted on the other device called the "slave" run `./sync.sh`.

Compared the displayed hashes, select Y if, and only if, they match. These are the hashes of each devices public key and if they don't match either there was a serious error or there is a man-in-the-middle attack going on.

They link will then automatically be set up.

## Dependencies

* Flask
* openssl

## Todo

* use iptables to forward/NAT traffic to allow bridging
* IPv6
* Use SPI screen and buttons on raspberry pi
