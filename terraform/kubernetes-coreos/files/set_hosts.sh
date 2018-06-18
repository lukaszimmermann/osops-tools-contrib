#!/bin/bash

set -e
echo "Setting the hostname"
IP_ADDR="$(ip route get 1 | awk '{print $NF;exit}')"
HOSTNAME="$(hostname)"

sudo echo "${IP_ADDR} ${HOSTNAME}" >> /etc/hosts 

