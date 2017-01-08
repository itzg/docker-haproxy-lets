#!/bin/sh

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

dopts=$(haproxy-gen_alpine certbot-args $generator_args)
primary_domain=$(haproxy-gen_alpine primary-domain $generator_args)

set -x
certbot certonly --standalone $dopts \
  --non-interactive --agree-tos $staging --email $EMAIL

mkdir -p /certs
cat /etc/letsencrypt/live/$primary_domain/privkey.pem /etc/letsencrypt/live/$primary_domain/fullchain.pem \
    > /certs/haproxy.pem

haproxy-gen_alpine generate $generator_args --out "$HAPROXY_CFG"
/docker-entrypoint.sh $@
