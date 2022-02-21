#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Verification of Certificates.

if [ "$1" = "-root" ]
then
    # verify root cert
    openssl x509 -noout -text -in ca/root/certs/ca.cert.pem

elif [ "$1" = "-intermediate" ]
then
    # verify intermediate cert
    openssl x509 -noout -text -in ca/intermediate/certs/intermediate.cert.pem

    # verify against root cert
    openssl verify -CAfile ca/root/certs/ca.cert.pem ca/intermediate/certs/intermediate.cert.pem

elif [ "$1" = "-webpolicy" ]
then
    # verify web policy cert
    openssl x509 -noout -text -in ca/webpolicy/certs/webpolicy.cert.pem
      
    # verify against intermediate cert
    openssl verify -CAfile ca/root/certs/ca.cert.pem -untrusted ca/intermediate/certs/intermediate.cert.pem ca/webpolicy/certs/webpolicy.cert.pem

elif [ "$1" = "-vpnpolicy" ]
then
    # verify vpn policy cert
    openssl x509 -noout -text -in ca/vpnpolicy/certs/vpnpolicy.cert.pem
      
    # verify against intermediate cert
    openssl verify -CAfile ca/root/certs/ca.cert.pem -untrusted ca/intermediate/certs/intermediate.cert.pem ca/vpnpolicy/certs/vpnpolicy.cert.pem

elif [ "$1" = "-codesignpolicy" ]
then
    # verify codesign policy cert
    openssl x509 -noout -text -in ca/codesignpolicy/certs/codesignpolicy.cert.pem
      
    # verify against intermediate cert
    openssl verify -CAfile ca/root/certs/ca.cert.pem -untrusted ca/intermediate/certs/intermediate.cert.pem ca/codesignpolicy/certs/codesignpolicy.cert.pem
else
    echo "Forgot to add -cert options"
    
fi