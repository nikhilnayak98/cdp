#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Automation of certificates deployment.

# GW1
if [ "$HOSTNAME" = "GW1" ]
then
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Deploy certificates for GW1 from deploy_certificates.sh    "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    # Deploy CA certs
    cp /hostlab/CA/certificates/ca/root/certs/ca.cert.pem /etc/ipsec.d/cacerts/
    cp /hostlab/CA/certificates/ca/intermediate/certs/intermediate.cert.pem /etc/ipsec.d/cacerts/
    cp /hostlab/CA/certificates/ca/vpnpolicy/certs/vpnpolicy.cert.pem /etc/ipsec.d/cacerts/

    # Deploy VPN client certs
    cp -r /hostlab/CA/certificates/vpn/certs /etc/ipsec.d/

    # Deploy VPN server Key
    cp -r /hostlab/CA/certificates/vpn/private/vpn_server_Key.pem /etc/ipsec.d/private/

# WWW
elif [ "$HOSTNAME" = "WWW" ]
then
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Deploy certificates for WWW from deploy_certificates.sh    "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    # Deploy SSL certs
    cp /hostlab/CA/certificates/server/server.cert.pem /etc/apache2/ssl/
    cp /hostlab/CA/certificates/server/server.key.pem /etc/apache2/ssl/private/

    # Deploy SSL cert chain
    cp /hostlab/CA/certificates/server/ca-bundle.pem /etc/apache2/ssl/

# Remote Staff machines (Regex Citation: https://unix.stackexchange.com/questions/617666/bash-match-regexes-for-both-different-hostnames)
elif [[ "$HOSTNAME" =~ ^Remote-Staff-[[:digit:]]$ ]]
then
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Deploy certificates for ${HOSTNAME} from deploy_certificates.sh"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    STAFFNUM=${HOSTNAME: -1}

    if [ $(( $STAFFNUM % 2 )) -eq 0 ]
    then
        # Deploy CA certs for GW1 VPN
        cp /hostlab/CA/certificates/ca/root/certs/ca.cert.pem /etc/ipsec.d/cacerts/
        cp /hostlab/CA/certificates/ca/intermediate/certs/intermediate.cert.pem /etc/ipsec.d/cacerts/
        cp /hostlab/CA/certificates/ca/vpnpolicy/certs/vpnpolicy.cert.pem /etc/ipsec.d/cacerts/

        # Deploy client specific cert
        cp /hostlab/CA/certificates/vpn/certs/Remote-Staff-$STAFFNUM-Cert.pem /etc/ipsec.d/certs/

        # Deploy client specific key
        cp /hostlab/CA/certificates/vpn/private/Remote-Staff-$STAFFNUM-Key.pem /etc/ipsec.d/private/
    fi

    # Deploy trusted certificates on client machine
    cp /hostlab/CA/certificates/ca/root/certs/ca.cert.pem /usr/local/share/ca-certificates/ca.cert.crt
    cp /hostlab/CA/certificates/ca/intermediate/certs/intermediate.cert.pem /usr/local/share/ca-certificates/intermediate.cert.crt
    cp /hostlab/CA/certificates/ca/webpolicy/certs/webpolicy.cert.pem /usr/local/share/ca-certificates/webpolicy.cert.crt
fi