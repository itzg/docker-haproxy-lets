#!/bin/sh

if [ x$EMAIL = x ]; then
  echo "-e EMAIL=... is required"
  exit 1
fi

if [ x$DOMAINS = x ]; then
  echo "-e DOMAINS=d1;d2;... is required"
  exit 1
fi

if [ x$BACKENDS = x ]; then
  echo "-e BACKENDS=host:port;h:p;... is required"
  exit 1
fi

if [ x$STAGING = xtrue ]; then
  staging="--staging"
fi

set -e

dopts=$(echo $DOMAINS | awk '{split($0,parts,";"); for (p in parts) printf(" -d %s", parts[p])}')
primaryDomain=$(echo $DOMAINS | awk '{split($0,parts,";"); parts[0]}')

bopts=$(echo $BACKENDS | awk '{split($0,parts,";"); for (p in parts) printf(" -b %s", parts[p])}')

set -x
certbot certonly --standalone $dopts \
  --non-interactive --agree-tos $staging --email $EMAIL

mkdir -p /etc/certs
cat /etc/letsencrypt/live/$primaryDomain/privkey.pem /etc/letsencrypt/live/$primaryDomain/fullchain.pem \
    > /etc/certs/haproxy.pem

haproxy-gen_alpine generate --template /etc/haproxy-templates $dopts $bopts > /usr/local/etc/haproxy/haproxy.cfg

/docker-entrypoint.sh $@
