#!/bin/bash
#
# 00-get-ca-certs-commission.sh - Get CA and casub from Artifactory
#
# --- Start MAAS 1.0 script metadata ---
# name: 00-get-ca-certs-commission.sh
# title: Get CA and casub from Artifactory
# description: Get CA and casub from Artifactory
# tags: comissioning
# script_type: commissioning
# --- End MAAS 1.0 script metadata --

mkdir -p /usr/local/share/ca-certificates
wget --no-check-certificate -O /usr/local/share/ca-certificates/nso-casub21.crt https://artifactory.company.com/artifactory/generic-local/com//ca-certificates/our-casub.crt
wget --no-check-certificate -O /usr/local/share/ca-certificates/RootCA.crt https://artifactory.company.com/artifactory/generic-local/com/ca-certificates/RootCA.cer
touch /etc/apt/apt.conf.d/99verify-peer.conf
echo "Acquire { https::Verify-Peer false }" >> /etc/apt/apt.conf.d/99verify-peer.conf
apt update &&  apt install -y ca-certificates
update-ca-certificates
