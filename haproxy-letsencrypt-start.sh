#!/bin/sh

# one week
renewInterval=604800
HAPROXY_CFG=/usr/local/etc/haproxy/haproxy.cfg

if [ x$EMAIL = x ]; then
  echo "-e EMAIL=... is required"
  exit 1
fi

if [ x$STAGING = xtrue ]; then
  staging="--staging"
fi

generator_args="--in "$GENERATOR_CONFIG""
if [ x$DOMAINS != x ]; then
  generator_args="$generator_args --domains $DOMAINS"
fi

set -e

dopts=$(${GENERATOR_DIR}/haproxy-gen certbot-args $generator_args)
primary_domain=$(${GENERATOR_DIR}/haproxy-gen primary-domain $generator_args)
mkdir -p /var/lib/haproxy

${GENERATOR_DIR}/haproxy-gen generate $generator_args --out "$HAPROXY_CFG"

fixCertFile() {
    src=/etc/letsencrypt/live/$primary_domain
    cp ${src}/fullchain.pem /certs/$primary_domain.pem
    cp ${src}/privkey.pem /certs/$primary_domain.pem.rsa
}

renew() {
    sleep $renewInterval

    # TODO
    # call certbot webroot
    # signal haproxy to reload

}

certbot certonly --standalone $dopts \
  --non-interactive --agree-tos $staging --email $EMAIL

fixCertFile

renew &

haproxy -f ${HAPROXY_CFG}
