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

haproxy-gen_alpine generate $generator_args --out "$HAPROXY_CFG"
/docker-entrypoint.sh $@
