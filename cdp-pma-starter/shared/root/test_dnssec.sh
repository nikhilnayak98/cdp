#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Test DNSSEC.

dig +dnssec gw1.u2185920.cyber21.test | grep -A1 HEADER
dig +dnssec gw2.u2185920.cyber21.test | grep -A1 HEADER
dig +dnssec www.u2185920.cyber21.test | grep -A1 HEADER