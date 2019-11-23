#!/bin/bash

DEBUG=1
MASTER_SLAVE=0
IP_BASE=192.168.42
IP_OFFSET=1
MASTER_IP=`printf %s.%s $IP_BASE $IP_OFFSET`
SLAVE_IP=`printf %s.%s $IP_BASE $(($IP_OFFSET + 1))`


ALICE_IFACE=eth0

while getopts ":ma:" OPT
do
  case $OPT in
    m)
      MASTER_SLAVE=1
      echo "Running as master";;
    a)
      ALICE_IFACE=$OPTARG
      echo "Using interface $OPTARG";;
    \?)
      echo "-m for Master mode\n-a eth0 to set interface to eth0"
      exit 1;;
  esac
done
shift $((OPTIND - 1))

ALICE_MAC=`cat /sys/class/net/$ALICE_IFACE/address`

echo "IFACE="$ALICE_IFACE > config

openssl genpkey -paramfile keys/params.pem -out keys/Alice.pem 2>/dev/null
openssl ec -in keys/Alice.pem -pubout -out keys/Alice.pub.pem 2>/dev/null

ip link set $ALICE_IFACE up
if [ $MASTER_SLAVE -eq 1 ]
then
  ip addr add `printf %s/24 $MASTER_IP` dev $ALICE_IFACE
else
  ip addr add `printf %s/24 $SLAVE_IP` dev $ALICE_IFACE
fi
HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ $MASTER_SLAVE -eq 1 ]
then
  python3 scripts/server.py
else
  PUBKEY=`cat keys/Alice.pub.pem|base64`
  wget -X POST --post-data "mac=$ALICE_MAC&pubkey=$PUBKEY" "http://$MASTER_IP:5000/public_key" -O keys/Bob.pub.pem
  wget "http://$MASTER_IP:5000/quit" -q0 &>/dev/null
fi

if [ $MASTER_SLAVE -eq 1 ]
then
  ip addr del `printf %s/24 $MASTER_IP` dev $ALICE_IFACE
else
  ip addr del `printf %s/24 $SLAVE_IP` dev $ALICE_IFACE
fi


NEW_HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ "$HASH" != "$NEW_HASH" ]
then
  echo "Error key was tampered with."
  exit -1
fi

if [ -f keys/Bob.pub.pem.b64 ]
then
  cat keys/Bob.pub.pem.b64 | base64 -d > keys/Bob.pub.pem
  rm keys/Bob.pub.pem.b64
fi

ALICE_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Alice.pub.pem -outform der 2>/dev/null|sha256sum|cut -d' ' -f1`
BOB_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Bob.pub.pem -outform der 2>/dev/null|sha256sum|cut -d' ' -f1`

if [ $MASTER_SLAVE -eq 1 ]
then
  echo $ALICE_HASH
  echo $BOB_HASH
else
  echo $BOB_HASH
  echo $ALICE_HASH
fi

if [ -f keys/shared_secret.bin ]
then
  rm keys/shared_secret.bin
fi

openssl pkeyutl -derive -inkey keys/Alice.pem -peerkey keys/Bob.pub.pem -out keys/shared_secret.bin

if [ ! -f keys/shared_secret.bin ]
then
  echo "Failed to derive shared secret."
  exit -1
fi

KEY=`openssl dgst keys/shared_secret.bin|cut -d' ' -f2`
MASTER_TX_KEY=${KEY:0:32}
SLAVE_TX_KEY=${KEY:32:64}

if [ $MASTER_SLAVE -eq 1 ]
then
  echo $MASTER_TX_KEY >> config
  echo $SLAVE_TX_KEY >> config
else
  echo $SLAVE_TX_KEY >> config
  echo $MASTER_TX_KEY >> config
fi

# Setup macsec $BOB_MAC $MASTER_TX_KEY $SLAVE_TX_KEY

if [ $DEBUG -ne 1 ]
then
   rm keys/Alice.* keys/Bob.* keys/shared_secret.bin
fi
