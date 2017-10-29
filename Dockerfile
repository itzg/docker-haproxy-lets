FROM haproxy:1.7-alpine

MAINTAINER itzg

RUN apk -U add certbot openssl

ENV GENERATOR_VER=0.1.2 \
    GENERATOR_DIR=/opt/haproxy-gen \
    GENERATOR_ETC=/etc/haproxy-gen \
    HAPROXY_PLUGIN_VER=0.1.1 \
    HAPROXY_PLUGIN_DIR=/opt/haproxy-acme-validation-plugin \
    HAPROXY_CFG=/usr/local/etc/haproxy/haproxy.cfg \
    GENERATOR_CONFIG=/config/haproxy-gen-cfg.yml

ADD https://github.com/itzg/haproxy-gen/releases/download/${GENERATOR_VER}/haproxy-gen_${GENERATOR_VER}_linux_64-bit.tar.gz /tmp/haproxy-gen.tgz
RUN mkdir -p ${GENERATOR_DIR} && \
    tar -C ${GENERATOR_DIR} -xvf /tmp/haproxy-gen.tgz && \
    rm /tmp/haproxy-gen.tgz && \
    mkdir -p ${GENERATOR_ETC}/templates && \
    ln -s ${GENERATOR_DIR}/*.tmpl ${GENERATOR_ETC}/templates

ADD https://github.com/janeczku/haproxy-acme-validation-plugin/archive/${HAPROXY_PLUGIN_VER}.tar.gz /tmp/plugin.tgz
RUN mkdir -p ${HAPROXY_PLUGIN_DIR} && \
    tar -C ${HAPROXY_PLUGIN_DIR} -xvf /tmp/plugin.tgz && \
    rm /tmp/plugin.tgz && \
    ln -s ${HAPROXY_PLUGIN_DIR}/acme-http01-webroot.lua /etc/haproxy

COPY haproxy-gen-cfg.yml /config/
COPY haproxy-letsencrypt-start.sh /opt/

VOLUME ["/config", "/certs", "/var/lib/haproxy"]
ENTRYPOINT ["/opt/haproxy-letsencrypt-start.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
