FROM nforceroh/d_alpine-s6:edge
LABEL maintainer="Sylvain Martin (sylvain@nforcer.com)"

ENV CERTBOT_ENABLE=false \
    CERTBOT_CF_TOKEN='' \
    CERTBOT_EMAIL='' \
    MAILNAME=mail.example.com \
    MYNETWORKS=127.0.0.0/8\ 10.0.0.0/8\ 172.16.0.0/12\ 192.168.0.0/16 \
    DB_HOST=10.0.0.101 \
    DB_USER=root \
    DB_PASSWORD=changeme \
    DB_DATABASE=mail \
    DOVECOT_HOST=10.0.0.101 \
    RSPAMD_HOST=10.0.0.101 \
    SSL_CERT=/etc/postfix/mail.crt \
    SSL_KEY=/etc/postfix/mail.key \
    WAITSTART_TIMEOUT=1m \
    RELAYHOST="mail.twc.com"
	
RUN echo "Installing postfix" \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 	&& apk update \
    && apk upgrade \
    && apk add --no-cache postfix postfix-mysql postfix-pcre policyd-spf-fs mariadb-client rspamd-client \
     ipset iptables ip6tables kmod nftables \
    && update-ca-certificates \
    && mkdir -p /etc/postfix/letsencrypt /etc/postfix/opendkim /etc/postfix/fail2ban \
    && ln -s /etc/postfix/letsencrypt /etc/letsencrypt \
    && ln -s /etc/postfix/opendkim /etc/opendkim \
    && ln -s /etc/postfix/fail2ban /etc/fail2ban \
    && apk add --no-cache certbot opendkim opendkim-utils fail2ban \
    && gpasswd -a postfix opendkim \
### cloudflare deps
	&& apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev \
    && pip install certbot-dns-cloudflare \
### Cleanup
    && apk del .build-deps \	
    && rm -rf /var/cache/apk/* /usr/src/* 

### Add Files
ADD install /

#Exposing tcp ports
EXPOSE 25 465 587

#Adding volumes
VOLUME ["/var/spool/postfix", "/etc/postfix"]
ENTRYPOINT ["/init"]