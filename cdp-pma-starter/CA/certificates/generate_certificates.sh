#!/bin/bash
# 
# Author : Nikhil Ranjan Nayak
# Web: https://github.com/nikhilnayak98/cdp
# Email: Nikhil-Ranjan.Nayak@warwick.ac.uk
# Description: Automation of certificates generation.
#              (Citation 1: Peter Norris, https://moodle.warwick.ac.uk/pluginfile.php/2339319/mod_folder/content/0/x509/x509.tar.gz?forcedownload=1)
#
#                               THREE TIER CERTIFICATE CHAIN
#
#                                     ###############
#                                     #   ROOT CA   #
#                                     ###############
#                                            |
#                                            |
#                                  #####################
#                                  #  INTERMEDIATE CA  #
#                                  #####################
#                                            |
#                                            |
#            +-------------------------------+---------------------------------+
#            |                               |                                 |
#   ###################             ###################              ######################
#   #  WEB POLICY CA  #             #  VPN POLICY CA  #              # CODESIGN POLICY CA #
#   ###################             ###################              ######################
#           |                                |                                 |
#           |                                |                                 |
#       #########       +------------+-------+-----+-------------+         ############
#       #  WWW  #       |            |             |             |         # CODESIGN #
#       #########   #########   ###########   ###########   ###########    ############
#                   #  GW1  #   # Staff-2 #   # Staff-4 #   # Staff-6 #
#                   #########   ###########   ###########   ###########
#
#


# generate passphrases using openssl
# openssl rand -base64 32
# Citation: https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
ROOTCAPASS="6AbefCHEUXksf4ORxKFzTxtZ9L0w79rOr92VEkHnzr4="
INTCAPASS="h0d6UVmln5F2fk55vqxRZWF4PbaFCx7qLLgos1LrSMc="
WEBCAPASS="iuLyE/a8C3ThPsw8ndUhBFeocWI5K5HXyyD8gXdfdS4="
VPNCAPASS="3dFrRHu5qRa1QF9Vy0zhEx5f3EEL/v67UiA6uCMAMOE="
CODESIGNCAPASS="JIIN2s4hYJTTIVKKkX2MXdx+O4jtfzwgyisaouMXcGE="

# set current directory as root directory
CERTSDIR=$PWD

# With bash's extended globbing, Citation- https://askubuntu.com/questions/890270/delete-folders-that-dont-have-a-character-in-their-name
shopt -s extglob

cd ca/root/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd ca/intermediate/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd ca/vpnpolicy/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd ca/webpolicy/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd ca/codesignpolicy/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd server/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd codesign/
rm -rf !(openssl.cnf)

cd $CERTSDIR
cd vpn/
rm -rf certs private reqs

cd $CERTSDIR
###########################
#         ROOT CA         #
###########################
echo "Creating Root CA"

# prep ca dirs
mkdir -p ca/root
cd ca/root/

mkdir certs crl newcerts private unsigned signed
chmod 700 private
touch index.txt
echo 1000 > serial

# create root CA key
openssl genrsa -aes256 -passout pass:$ROOTCAPASS -out private/ca.key.pem 2048
chmod 400 private/ca.key.pem

# create root cert valid for 25 years
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -passin pass:$ROOTCAPASS \
      -new -x509 \
      -days 9165 \
      -sha256 \
      -extensions v3_ca \
      -out certs/ca.cert.pem \
      -batch

echo "Root CA Created"
##################################################################


###########################
#     INTERMEDIATE CA     #
###########################
echo "Creating Intermediate CA"

cd $CERTSDIR
mkdir -p ca/intermediate
cd ca/intermediate/

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# create intermediate CA key
openssl genrsa -aes256 -passout pass:$INTCAPASS -out private/intermediate.key.pem 2048
chmod 400 private/intermediate.key.pem

########## ROOT CA SIGNS INTERMEDIATE CA ##############
# create intermediate cert signing request
openssl req -config openssl.cnf \
      -new -sha256 \
      -passin pass:$INTCAPASS \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem \
      -batch

# send intermediate csr to the root ca
cd $CERTSDIR
cp ca/intermediate/csr/intermediate.csr.pem ca/root/unsigned/

# get the intermediate cert signed by the root cert valid for 10 years
cd ca/root/
openssl ca -config openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -passin pass:$ROOTCAPASS \
      -in unsigned/intermediate.csr.pem \
      -out signed/intermediate.cert.pem \
      -batch
      
# return it to intermediate ca
cd $CERTSDIR
cp ca/root/signed/intermediate.cert.pem ca/intermediate/certs/
chmod 444 ca/intermediate/certs/intermediate.cert.pem

echo "Intermediate CA Created"
##################################################################


###########################
#      WEB POLICY CA      #
###########################
echo "Creating Web Policy CA"

cd $CERTSDIR
mkdir -p ca/webpolicy
cd ca/webpolicy/

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# create webpolicy CA key
openssl genrsa -aes256 -passout pass:$WEBCAPASS -out private/webpolicy.key.pem 2048
chmod 400 private/webpolicy.key.pem

########## INTERMEDIATE CA SIGNS WEB POLICY CA ##############
# create intermediate cert signing request
openssl req -config openssl.cnf \
      -new -sha256 \
      -passin pass:$WEBCAPASS \
      -key private/webpolicy.key.pem \
      -out csr/webpolicy.csr.pem \
      -batch

# send web policy csr to the intermediate ca
cd $CERTSDIR
cp ca/webpolicy/csr/webpolicy.csr.pem ca/intermediate/unsigned/

# get the web policy cert signed by the intermediate cert valid for 5 years
cd ca/intermediate/
openssl ca -config openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 1825 -notext -md sha256 \
      -passin pass:$INTCAPASS \
      -in unsigned/webpolicy.csr.pem \
      -out signed/webpolicy.cert.pem \
      -batch
      
# return it to web policy ca
cd $CERTSDIR
cp ca/intermediate/signed/webpolicy.cert.pem ca/webpolicy/certs/
chmod 444 ca/webpolicy/certs/webpolicy.cert.pem

echo "Web Policy CA Created"
##################################################################


###########################
#      VPN POLICY CA      #
###########################
echo "Creating VPN Policy CA"

cd $CERTSDIR
mkdir -p ca/vpnpolicy
cd ca/vpnpolicy/

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# create vpn policy CA key
openssl genrsa -aes256 -passout pass:$VPNCAPASS -out private/vpnpolicy.key.pem 2048
chmod 400 private/vpnpolicy.key.pem

########## INTERMEDIATE CA SIGNS VPN POLICY CA ##############
# create intermediate cert signing request
openssl req -config openssl.cnf \
      -new -sha256 \
      -passin pass:$VPNCAPASS \
      -key private/vpnpolicy.key.pem \
      -out csr/vpnpolicy.csr.pem \
      -batch

# send vpn policy csr to the intermediate ca
cd $CERTSDIR
cp ca/vpnpolicy/csr/vpnpolicy.csr.pem ca/intermediate/unsigned/

# get the vpn policy cert signed by the intermediate cert valid for 5 years
cd ca/intermediate/
openssl ca -config openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 1825 -notext -md sha256 \
      -passin pass:$INTCAPASS \
      -in unsigned/vpnpolicy.csr.pem \
      -out signed/vpnpolicy.cert.pem \
      -batch
      
# return it to vpn policy ca
cd $CERTSDIR
cp ca/intermediate/signed/vpnpolicy.cert.pem ca/vpnpolicy/certs/
chmod 444 ca/vpnpolicy/certs/vpnpolicy.cert.pem

echo "VPN Policy CA Created"
##################################################################


###########################
#   CODESIGN POLICY CA    #
###########################
echo "Creating CodeSign Policy CA"

cd $CERTSDIR
mkdir -p ca/codesignpolicy
cd ca/codesignpolicy/

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# create codesign policy CA key
openssl genrsa -aes256 -passout pass:$CODESIGNCAPASS -out private/codesignpolicy.key.pem 2048
chmod 400 private/codesignpolicy.key.pem

########## INTERMEDIATE CA SIGNS CODESIGN POLICY CA ##############
# create intermediate cert signing request
openssl req -config openssl.cnf \
      -new -sha256 \
      -passin pass:$CODESIGNCAPASS \
      -key private/codesignpolicy.key.pem \
      -out csr/codesignpolicy.csr.pem \
      -batch

# send codesign policy csr to the intermediate ca
cd $CERTSDIR
cp ca/codesignpolicy/csr/codesignpolicy.csr.pem ca/intermediate/unsigned/

# get the codesign policy cert signed by the intermediate cert valid for 5 years
cd ca/intermediate/
openssl ca -config openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 1825 -notext -md sha256 \
      -passin pass:$INTCAPASS \
      -in unsigned/codesignpolicy.csr.pem \
      -out signed/codesignpolicy.cert.pem \
      -batch

# return it to codesign policy ca
cd $CERTSDIR
cp ca/intermediate/signed/codesignpolicy.cert.pem ca/codesignpolicy/certs/
chmod 444 ca/codesignpolicy/certs/codesignpolicy.cert.pem

echo "CodeSign Policy CA Created"
##################################################################


###########################
#           WWW           #
###########################
echo "Creating WWW Certificate"

cd $CERTSDIR
mkdir server
cd server

# generate server key (no aes256 to permit server unattended restart)
openssl genrsa -out server.key.pem 2048
chmod 400 server.key.pem

######### WEB POLICY CA SIGNS WWW CSR #################
# generate server cert signing request
openssl req -config openssl.cnf \
      -key server.key.pem \
      -new -sha256 \
      -out server.csr.pem \
      -batch

# send server csr to the web policy ca
cd $CERTSDIR
cp server/server.csr.pem ca/webpolicy/unsigned/

# get the server cert signed by the web policy cert valid for 2 years
cd ca/webpolicy/
openssl ca -config openssl.cnf \
      -extensions server_cert \
      -days 730 \
      -notext -md sha256 \
      -passin pass:$WEBCAPASS \
      -in unsigned/server.csr.pem \
      -out signed/server.cert.pem \
      -batch

# return it to the server
cd $CERTSDIR
cp ca/webpolicy/signed/server.cert.pem server/  
chmod 444 server/server.cert.pem

# create certificate chain for apache2 ssl config
cat ca/root/certs/ca.cert.pem >> server/ca-bundle.pem
cat ca/intermediate/certs/intermediate.cert.pem >> server/ca-bundle.pem
cat ca/webpolicy/certs/webpolicy.cert.pem >> server/ca-bundle.pem

echo "WWW Certificate Created"
##################################################################


###########################
#        CODESIGN         #
###########################
echo "Creating CodeSign Certificate"

cd $CERTSDIR
mkdir codesign
cd codesign

# generate codesign key
openssl genrsa -out codesign.key.pem 2048
chmod 400 codesign.key.pem

######### CODESIGN POLICY CA SIGNS CODESIGN CSR #################
# generate codesign cert signing request
openssl req -config openssl.cnf \
      -key codesign.key.pem \
      -new -sha256 \
      -out codesign.csr.pem \
      -batch

# send codesign csr to the codesign policy ca
cd $CERTSDIR
cp codesign/codesign.csr.pem ca/codesignpolicy/unsigned/

# get the codesign cert signed by the codesign policy cert valid for 2 years
cd ca/codesignpolicy/
openssl ca -config openssl.cnf \
      -extensions codesign_reqext \
      -days 730 \
      -passin pass:$CODESIGNCAPASS \
      -notext -md sha256 \
      -in unsigned/codesign.csr.pem \
      -out signed/codesign.cert.pem \
      -batch

# return it to the codesign
cd $CERTSDIR
cp ca/codesignpolicy/signed/codesign.cert.pem codesign/  
chmod 444 codesign/codesign.cert.pem

echo "CodeSign Certificate Created"
##################################################################


###########################
#           GW1           #
###########################
echo "VPN CA Passphrase: $VPNCAPASS"
echo "Creating GW1 Certificate"

cd $CERTSDIR
cd vpn
mkdir certs private reqs

# generate private key for GW1
pki --gen \
  --type rsa \
  --size 2048 \
  --outform pem > private/vpn_server_Key.pem
  
chmod 600 private/vpn_server_Key.pem

# generate cert signing request
pki --pub \
  --in private/vpn_server_Key.pem \
  --type rsa \
  --outform pem > reqs/vpn_server_csr.pem

######### VPN POLICY CA SIGNS GW1 CSR #################
# valid for 2 years
pki --issue \
  --in reqs/vpn_server_csr.pem \
  --lifetime 730 \
  --cacert ../ca/vpnpolicy/certs/vpnpolicy.cert.pem \
  --cakey ../ca/vpnpolicy/private/vpnpolicy.key.pem \
  --dn "C=UK, ST=England, L=Warwickshire, O=University of Warwick, OU=WMG Cyber Security Centre (GW1 VPN), CN=gw1.u2185920.cyber21.test" \
  --san 213.0.133.162  \
  --san @213.0.133.162 \
  --flag serverAuth \
  --flag ikeIntermediate \
  --outform pem > certs/vpn_server_Cert.pem

echo "GW1 Certificate Created"
##################################################################


###########################
#          STAFFs         #
###########################
for i in {2..6..2}
do
      echo "Creating Remote-Staff-$i Certificate"

	# generate private key for Staff-i
	pki --gen \
	  --type rsa \
	  --size 2048 \
	  --outform pem > private/Remote-Staff-$i-Key.pem

	# generate cert signing request for Staff-i
	pki --pub \
	  --in private/Remote-Staff-$i-Key.pem \
	  --type rsa \
	  --outform pem > reqs/Remote-Staff-$i\_csr.pem
	
	######### VPN POLICY CA SIGNS STAFF-i CSR #################
	pki --issue \
        --in reqs/Remote-Staff-$i\_csr.pem \
	  --lifetime 730 \
	  --cacert ../ca/vpnpolicy/certs/vpnpolicy.cert.pem \
        --cakey ../ca/vpnpolicy/private/vpnpolicy.key.pem \
        --dn "C=UK, ST=England, L=Warwickshire, O=University of Warwick, OU=WMG Cyber Security Centre (GW1 VPN), CN=staff$i.u2185920.cyber21.test" \
        --flag clientAuth \
        --flag ikeIntermediate \
        --outform pem > certs/Remote-Staff-$i-Cert.pem
	
	echo "Remote-Staff-$i Certificate Created"
done
##################################################################