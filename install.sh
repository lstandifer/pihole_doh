#!/bin/bash

# install basic packages
apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y install bash

# install cloudflared

cd /tmp \
    && wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
    && cp ./cloudflared /usr/local/bin \
    && useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared
    
# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml

# add cloudflared config
cd /tmp \
    && mkdir -p /etc/cloudflared \
    && cp -n ./config.yaml /etc/cloudflared/ \
    && rm -f ./config.yaml

# run cloudflared as service
mkdir -p /etc/services.d/cloudflared \
    && echo '#!/usr/bin/with-contenv bash' > /etc/services.d/cloudflared/run \
    && echo 's6-echo "Starting cloudflared"' >> /etc/services.d/cloudflared/run \
    && echo '/usr/local/bin/cloudflared --config /etc/cloudflared/config.yaml' >> /etc/services.d/cloudflared/run \
    && echo '#!/usr/bin/with-contenv bash' > /etc/services.d/cloudflared/finish \
    && echo 's6-echo "Stopping cloudflared"' >> /etc/services.d/cloudflared/finish \
    && echo 'killall -9 cloudflared' >> /etc/services.d/cloudflared/finish
	
# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
