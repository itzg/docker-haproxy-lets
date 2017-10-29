#!/bin/sh

# try renew every 12 hours
#renewInterval=43200
renewInterval=60
haproxyCfg=/config/haproxy.cfg
certbotOpts="--non-interactive --config-dir /certs --agree-tos"
haproxyPidFile=/var/run/haproxy.pid

if [ x$DEBUG = xtrue ]; then
  set -x
fi

if [ x$EMAIL = x ]; then
  echo "-e EMAIL=... is required"
  exit 1
fi
certbotOpts="$certbotOpts --email $EMAIL"

if [ x$STAGING = xtrue ]; then
  certbotOpts="$certbotOpts --staging"
fi

if [ -f /config/domains ]; then
  DOMAINS=$(cat /config/domains)
else
  if [ x$DOMAINS = x ]; then
    echo "-e DOMAINS=... is required"
    exit 1
  fi
  echo $DOMAINS > /config/domains
fi

generatorOpts="--domains=$DOMAINS --in $GEN_CFG"

set -e

domainOpts=$(${GENERATOR_DIR}/haproxy-gen certbot-args $generatorOpts)
primaryDomain=$(${GENERATOR_DIR}/haproxy-gen primary-domain $generatorOpts)
pemBundle=/certs/$primaryDomain.pem


fixCertFile() {
  src=/certs/live/$primaryDomain
  cat ${src}/fullchain.pem ${src}/privkey.pem > $pemBundle
}

reloadHaproxy() {
  pid=$(ps -o pid,comm | awk '$2 == "haproxy-systemd" {print $1}')
  echo "reloading haproxy wrapper at $pid"
  kill -HUP $pid
}

manageCerts() {
  while ! netstat -nl|grep :80 >& /dev/null; do
    sleep 5
  done

  set -e
  echo "INIT: Using certbot to initialize certs"
  certbot certonly $certbotOpts --webroot --webroot-path $WEBROOT --expand --allow-subset-of-names $domainOpts
  fixCertFile

  ${GENERATOR_DIR}/haproxy-gen generate $generatorOpts --out $haproxyCfg
  reloadHaproxy

  while true; do 
    renew 
  done
}

renew() {
  echo "RENEW: waiting $renewInterval seconds..."
  sleep $renewInterval

  echo "RENEW: calling certbot"
  certbot renew $certbotOpts | tee /tmp/renew.log
  if grep "No renewals were attempted" /tmp/renew.log; then
    echo "RENEW: skipping"
  else
    echo "RENEW: reloading"
    fixCertFile
    reloadHaproxy
  fi
}

if [ ! -f $pemBundle ]; then
  disableCerts="--disable-certs"
fi

${GENERATOR_DIR}/haproxy-gen generate $generatorOpts $disableCerts --out $haproxyCfg

manageCerts &

echo "Starting haproxy"
/usr/local/sbin/haproxy-systemd-wrapper -p /run/haproxy.pid -d -f ${haproxyCfg}
