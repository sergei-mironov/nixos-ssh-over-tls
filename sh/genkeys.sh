#!/bin/sh

CWD=`pwd`
U=`id -un`
G=`id -gn`

cat >_stunnel_test_setver.cfg <<EOF
cert=$CWD/stunnel.pem
pid=$CWD/stunnel.pid
setuid = $U
setgid = $G
foreground = yes
output = /dev/stdout
[ssh]
accept = 443
connect = 127.0.0.1:2222
EOF

# cd /etc/ssl
openssl genrsa 2048 > stunnel.key
openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
cat stunnel.crt stunnel.key > stunnel.pem
chmod 600 stunnel.pem

chmod 600 stunnel.pem
chown $U:$G stunnel.pem

# touch $CWD/stunnel.pid
# chown $U:$G $CWD/stunnel.pid
# stunnel _stunnel_test_setver.cfg


