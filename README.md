# Cryptosystems and Data Protection

A scalable PKI infrastructure with a three tier certificate authority hierarchy with automated certificates generation and deployment. It housed StrongSwan IPSec gateway and a WireGuard VPN gateway. MACSec was configured for LAN-LAN Data Link Layer encryption with replay protection. A DarkNet is set up using an isolated TOR environment with a private TOR directory authority and relays.

## Network Design
![Network Design](https://raw.githubusercontent.com/nikhilnayak98/cdp/main/Network%20Design.png)

## Certificate Authority Hierarchy
![Certificate](https://raw.githubusercontent.com/nikhilnayak98/cdp/main/Certificate%20Authority%20Hierarchy.png)

## Phase 1

- [x] 1. satisfy the case-sensitive file-naming requirements of the deliverable files.
- [x] 2. define and implement a credible x509 certificate hierarchy, consistent with the script of instructions.
- [x] 3. submit a GPG public key that is consistent and valid until at least November 2023.
- [x] 4. provide the correct GPG fingerprint of the public key on the front cover of your pdf submission.
- [x] 5. have a digital signature that successfully verifies the submitted targz against the supplied public key.
- [x] 6. achieve VPN connectivity for at least one sample mobile worker over IPSec.
- [x] 7. have evidence that the VPN functions correctly.
- [x] 8. correctly use allocated IP addresses and domain names.
- [x] 9. have hashes at the demonstration that match the hashes in the submission.

## Phase 2

- [x] 10. make a compelling case for your scalable design and implementation of the IPSec VPN using the x509 certificate authority hierarchy as appropriate, permitting multiple workers to achieve connectivity.
- [x] 11. have your submitted public key signed by at least three other submitted public keys.
- [x] 12. have correctly used the private key associated with the submitted public key, to sign three other submitted public keys.
- [x] 13. have clean, robust, maintainable, well organised, well commented configuration files throughout.
- [x] 14. respond successfully to the challenge, encrypted against the public key that you submitted as a deliverable.

## Phase 3

- [x] 15. implement several sample mobile workers with successful VPN connectivity to both gateways.
- [x] 16. make a succinct but compelling evaluation of your VPN configurations.
- [x] 17. implement a robust HTTPS configuration of the Apache web-server.
- [x] 18. make a compelling case for your HTTPS implementation.
- [x] 19. make thoughtful use of sub-keys, key size and key validity periods in your submission.
- [x] 20. have your signed public key, available on as many of the following keyservers as are functional just prior to the submission deadline:
  - [ ] <code>hkp://pool.sks-keyservers.net</code> [Link](https://sks-keyservers.net/)
  - [x] <code>hkp://keyserver.ubuntu.com</code> [Link](https://keyserver.ubuntu.com/)
  - [x] <code>hkp://keyserver.2ndquadrant.com</code> [Link](https://keyserver.2ndquadrant.com/)
- [x] 21. demonstrate comprehensive mastery of all aspects of the the submission at all scales (detail through to overall concept). This should be reinforced by at least one additional crypto related feature of your choice.

## Augmented Features:

1. Implementation of 3 tier x509 certificate hierarchy.
2. Layer 2 encryption using MACSec.
3. Implementation of DarkNet using TOR.
4. DarkWeb using TOR Hidden Services.
5. Automation of x509 certificates generation.
6. Automation of certificates deployment.
7. Apache2 configuration against CRIME attacks.

## How to Run Lab
- <code>cd cdp-pma-starter</code>
- <code>chmod +x /shared/deploy_certificates.sh start_lab.sh</code>
- To start entire lab without Tor infrastructure
- <code>./start_lab.sh</code>
- To start entire lab with Tor infrastructure
- <code>./start_lab.sh --with-tor</code>
- To start Tor infrastructure
- <code>./start_lab.sh --tor-only</code>
- To start IPSec infrastructure
- <code>./start_lab.sh --ipsec</code>
- To start WireGuard infrastructure
- <code>./start_lab.sh --wg</code>
