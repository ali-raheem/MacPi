#!/bin/bash

rm -f keys/shared_secret.bin

openssl pkeyutl -derive -inkey keys/Alice.pem -peerkey keys/Bob.pub.pem -out keys/shared_secret.bin
