FROM haproxy:1.7-alpine

MAINTAINER itzg

RUN apk -U add certbot openssl

ENV GENERATOR_VER=0.0.12 \
    HAPROXY_CFG=/usr/local/etc/haproxy/haproxy.cfg \
    GENERATOR_ETC=/etc/haproxy-gen \
    GENERATOR_CONFIG=/config/haproxy-gen-cfg.yml \
    GENERATOR_TMPL_HASH=a7a8e6c1237a6660389b33c38312fe7a7c811a4d

ADD https://github.com/itzg/haproxy-gen/releases/download/${GENERATOR_VER}/haproxy-gen_alpine.tgz /tmp/haproxy-gen_alpine.tgz
RUN tar xvf /tmp/haproxy-gen_alpine.tgz -C /usr/bin ; rm /tmp/haproxy-gen_alpine.tgz
ADD https://raw.githubusercontent.com/itzg/haproxy-gen/${GENERATOR_TMPL_HASH}/haproxy.cfg.tmpl ${GENERATOR_ETC}/templates/haproxy.cfg.tmpl

COPY haproxy-letsencrypt-start.sh /opt/
COPY haproxy-gen-cfg.yml /config/

VOLUME ["/config", "/certs"]
ENTRYPOINT ["/opt/haproxy-letsencrypt-start.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
