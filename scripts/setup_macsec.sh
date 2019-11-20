#!/bin/bash
ALICE_INTERFACE="enp4s0"
ALICE_KEY="886ae1a8eb4944b87cb00844ec19bfc8"
BOB_KEY="ae9d00bdfeb06459881048b704689e8c"
BOB_MAC="b4:2e:99:1d:20:2d"

ip link add link $ALICE_INTERFACE macsec0 type macsec encrypt on
ip macsec add macsec0 rx port 1 address $BOB_MAC
ip macsec add macsec0 tx sa 0 pn 1 on key 00 $ALICE_KEY
ip macsec add macsec0 rx port 1 address $BOB_MAC sa 0 pn 1 on key 00 $BOB_KEY
