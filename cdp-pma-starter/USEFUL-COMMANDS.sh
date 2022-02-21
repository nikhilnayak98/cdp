# Test DNS Server
host -t a <domain name> <ip of DNS server>

host -t a www.u2185920.cyber21.test 8.8.8.8
host -t a gw1.u2185920.cyber21.test 8.8.8.8
host -t a gw2.u2185920.cyber21.test 8.8.8.8

# Web page retrieval
wget https://www.u2185920.cyber21.test
wget --no-check-certificate https://www.u2185920.cyber21.test

# Restart automation
alias lr='f(){ lcrash "$@"; lstart "$@"; unset -f f; }; f'
alias start='f(){ ./start_lab.sh "$@"; ./start_lab.sh "$@"; unset -f f; }; f'

# Set nameserver
echo 'nameserver 1.1.1.1' > /etc/resolv.conf
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# Tests
curl https://www.u2185920.cyber21.test

# Check ipsec logs
tail -f /var/log/syslog
