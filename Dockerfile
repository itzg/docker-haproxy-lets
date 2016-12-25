FROM haproxy:1.7-alpine

MAINTAINER itzg

RUN apk -U add certbot openssl

ADD https://github.com/itzg/haproxy-gen/releases/download/0.0.9/haproxy-gen_alpine.tgz /tmp/haproxy-gen_alpine.tgz
RUN tar xvf /tmp/haproxy-gen_alpine.tgz -C /usr/bin ; rm /tmp/haproxy-gen_alpine.tgz

COPY templates/ /etc/haproxy-templates/

COPY haproxy-letsencrypt-start.sh /

ENTRYPOINT ["/haproxy-letsencrypt-start.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
