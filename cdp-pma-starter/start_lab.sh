#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Automation script for starting netkit machines with or without tor.

DISPLAY=:0 xdotool mousemove 100 300
DISPLAY=:0 xdotool click 1

if [ "$1" = "--tor-only" ]
then
    lstart Internet Tor-*
    echo "Started tor infrastructure only"
elif [ "$1" = "--with-tor" ]
then
    lstart
    echo "Started with tor infrastructure"
elif [ "$1" = "--ipsec" ]
then
    lstart Internet Ext-DNS Remote-Staff-2 Remote-Staff-4 Remote-Staff-6 Hotel-Router Edge-Router GW1 Int-WWW
    echo "Started ipsec infrastructure"
elif [ "$1" = "--wg" ]
then
    lstart Internet Ext-DNS Remote-Staff-1 Remote-Staff-3 Remote-Staff-5 Hotel-Router Edge-Router GW2
    echo "Started wireguard infrastructure"
else
    lstart Internet Ext-DNS Remote-Staff-* Hotel-Router Edge-Router GW* WWW Int-WWW
    echo "Started without tor infrastructure"
fi