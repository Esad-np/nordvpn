FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
LABEL maintainer="Julio Gutierrez julio.guti+nordvpn@pm.me"

ARG NORDVPN_VERSION=3.20.2
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y curl iputils-ping libc6 wireguard && \
    apt-get install -y vim && \
    curl https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn-release/nordvpn-release_1.0.0_all.deb --output /tmp/nordrepo.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update -y && \
    apt-get install -y nordvpn${NORDVPN_VERSION:+=$NORDVPN_VERSION} && \
    apt-get remove -y nordvpn-release && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY /rootfs /
COPY startup.sh .
RUN chmod +x /etc/cont-init.d/* && \
    chmod +x /etc/services.d/nordvpn/* && \
    chmod +x /etc/fix-attrs.d/* && \
    chmod +x /usr/bin/no* && \
    chmod +x /usr/bin/he* && \
    chmod +x startup.sh
ENV S6_CMD_WAIT_FOR_SERVICES=1
HEALTHCHECK --start-period=30s --timeout=5s --interval=2m --retries=3 CMD bash /usr/bin/healthcheck
CMD [ "./startup.sh" ]
