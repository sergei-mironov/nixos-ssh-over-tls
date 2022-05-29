#!/bin/sh

CWD=`pwd`
U=`id -un`
G=`id -gn`

parse_proxy() {
  local proxy=$http_proxy
  U=`echo $proxy | tr ':@' '  ' | awk '{print $1}'`
  P=`echo $proxy | tr ':@' '  ' | awk '{print $2}'`
  H=`echo $proxy | tr ':@' '  ' | awk '{print $3}'`
  Po=`echo $proxy | tr ':@' '  ' | awk '{print $4}'`
}

parse_proxy

LISTEN_PORT=3443
while test -n "$1" ; do
  case "$1" in
    -h|--help) echo "Usage: $0 [-L PORT] HOST[:PORT]" >&2 ; exit 1 ;;
    -L) LISTEN_PORT=$2 ; shift ;;
    *) TLS_HOST=`echo $1 | tr ':@' '  ' | awk '{print $1}'`
       TLS_PORT=`echo $1 | tr ':@' '  ' | awk '{print $2}'`
       if test -z "$PORT" ; then
         TLS_PORT=443
       fi
       ;;
  esac
  shift 1
done

if test -z "$TLS_HOST"; then
  echo "Specify HOST[:PORT] to connect to using TLS" >&2
  exit 1
fi

touch $CWD/_stunnel.pid
chown $U:$G $CWD/_stunnel.pid

cat >_stunnel_client.cfg <<EOF
cert=$CWD/stunnel.pem
pid=$CWD/_stunnel.pid
client=yes
# setuid = stunnel
# setgid = stunnel
foreground = yes
output = /dev/stdout
debug = 7
[ssh]
accept=$LISTEN_PORT
connect=$TLS_HOST:$TLS_PORT
# protocol = connect
# protocolUsername = $U
# protocolPassword = $P
# connect=$H:$Po
EOF

stunnel _stunnel_client.cfg

