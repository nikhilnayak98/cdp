#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Tor Directory Authority configuration.

# use public ip address
ipaddress="5.151.132.2"

# stop all running tor instances
/etc/init.d/tor stop
pkill -9 tor

# create directory for tor keys and certs
sudo -u debian-tor mkdir /var/lib/tor/keys

# generate tor certificate and keys valid for 2 years
sudo -u debian-tor tor-gencert --create-identity-key -m 24 -a $ipaddress:7000 \
            -i /var/lib/tor/keys/authority_identity_key \
            -s /var/lib/tor/keys/authority_signing_key \
            -c /var/lib/tor/keys/authority_certificate

# list fingerprint to check certificates have been generated or not
sudo -u debian-tor tor --list-fingerprint --orport 1 \
    --dirserver "x 127.0.0.1:1 ffffffffffffffffffffffffffffffffffffffff" \
    --datadirectory /var/lib/tor/

finger1=$(sudo cat /var/lib/tor/keys/authority_certificate  | grep fingerprint | cut -f 2 -d ' ')
finger2=$(sudo cat /var/lib/tor/fingerprint | cut -f 2 -d ' ')

# cat into /etc/tor/torrc file
sudo bash -c "cat >/etc/tor/torrc <<EOL
TestingTorNetwork 1
DataDirectory /var/lib/tor
RunAsDaemon 1
ConnLimit 60
Nickname TorDA
ShutdownWaitLength 0
PidFile /var/lib/tor/pid
Log notice file /var/log/tor/notice.log
Log info file /var/log/tor/info.log
Log debug file /var/log/tor/debug.log
ProtocolWarnings 1
SafeLogging 0
DisableDebuggerAttachment 0
DirAuthority TorDA orport=5000 no-v2 hs v3ident=$finger1 $ipaddress:7000 $finger2
SocksPort 0
OrPort 5000
ControlPort 9051
Address $ipaddress
DirPort 7000
ExitPolicy accept *:*
AuthoritativeDirectory 1
V3AuthoritativeDirectory 1
ContactInfo auth0@test.test
#ExitPolicy reject *:*
V3AuthVotingInterval 300
V3AuthVoteDelay 20
V3AuthDistDelay 20
TestingV3AuthInitialVotingInterval 300
TestingV3AuthInitialVoteDelay 20
TestingV3AuthInitialDistDelay 20
AssumeReachable 1
EOL"

# for distributing config to tor relays over netkit network
bash -c "cat >/var/www/html/relay.conf <<EOL
TestingTorNetwork 1
DataDirectory /var/lib/tor
RunAsDaemon 1
ConnLimit 60
ShutdownWaitLength 0
PidFile /var/lib/tor/pid
Log notice file /var/log/tor/notice.log
Log info file /var/log/tor/info.log
Log debug file /var/log/tor/debug.log
ProtocolWarnings 1
SafeLogging 0
DisableDebuggerAttachment 0
DirAuthority TorDA orport=5000 no-v2 hs v3ident=$finger1 $ipaddress:7000 $finger2
SocksPort 0
OrPort 5000
ControlPort 9051
#ExitPolicy accept 192.168.0.0/16:*
ExitPolicy accept *:*
AssumeReachable 1
PathsNeededToBuildCircuits 0.25
TestingDirAuthVoteExit *
TestingDirAuthVoteHSDir *
V3AuthNIntervalsValid 2
TestingDirAuthVoteGuard *
TestingMinExitFlagThreshold 0
Sandbox 1
EOL"

# for distributing config to tor clients over netkit network
bash -c "cat >/var/www/html/client.conf <<EOL
TestingTorNetwork 1
DataDirectory /var/lib/tor
RunAsDaemon 1
ConnLimit 60
ShutdownWaitLength 0
PidFile /var/lib/tor/pid
Log notice file /var/log/tor/notice.log
Log info file /var/log/tor/info.log
Log debug file /var/log/tor/debug.log
ProtocolWarnings 1
SafeLogging 0
DisableDebuggerAttachment 0
DirAuthority TorDA orport=5000 no-v2 hs v3ident=$finger1 $ipaddress:7000 $finger2
SocksPort 9050
ControlPort 9051
EOL"