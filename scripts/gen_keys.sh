#!/bin/bash

openssl genpkey -paramfile keys/params.pem -out keys/Alice.pem 2>/dev/null
openssl ec -in keys/Alice.pem -pubout -out keys/Alice.pub.pem 2>/dev/null
