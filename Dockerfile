#THIS DOCKERFILE IS OPTIMIZED TO Raspberry pi 4 and Raspbian ARM64 (aarch64) platform
FROM node:16-buster-slim
LABEL maintainer="cslev <cslev@gmx.com>"
#ARG branch=master

ENV DEPS gettext \
         net-tools \ 
        #  ethtool \
        #  dnsutils \
         nano \
         ca-certificates \
         bash \
         iputils-ping \
         sudo

ENV BUILD_DEPS  git \
                make \
                gcc \
                automake-1.15 \
                libc6-dev
                
#ENV NODE_ENV production 

COPY sources /tmp/
WORKDIR /opt/magic_mirror
#COPY source/mm-docker-config.js source/docker-entrypoint.sh ./


RUN set -e; \
    #installing deps
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y;\
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y;\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $DEPS;\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BUILD_DEPS;\
    #lol_dht22 is needed for aarch64, pure wiringpi+dht_var do not work
    # The commands below are for reference, it is compiled and binary attached to reduce resource usage
    git clone https://github.com/guation/WiringPi-arm64.git; \
    cd WiringPi-arm64/; \
    ./build;\
    cd ..;\
    git clone https://github.com/technion/lol_dht22; \
    cd lol_dht22;\
    ./configure;\
    make;\
    #cleaning
    DEBIAN_FRONTEND=noninteractive apt-get remove -y $BUILD_DEPS; \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y;\
    apt-get clean;\
    rm -rf /var/lib/apt/lists/*; \
    #install MM
    git clone https://github.com/MichMich/MagicMirror.git . ;\
    cp -R modules /opt/default_modules;\
    cp -R config /opt/default_config;\
    cp -R css /opt/default_css;\
    cp -R js /opt/default_js;\
    npm install --unsafe-perm --silent;\
    cp /tmp/mm-docker-config.js ./config/config.js;\
    chmod +x /tmp/docker-entrypoint.sh;\
    cp /tmp/docker-entrypoint.sh ./;\
    #load custom bashrc that contains coloring and shortened install commands
    mv /tmp/bashrc_template /root/.bashrc; \
    . /root/.bashrc;

EXPOSE 8080
#basic first settings + install extra deps provided via docker env vars at runtime
ENTRYPOINT ["./docker-entrypoint.sh"]
#run node server, i.e., run MM
#CMD ["bash"]
CMD ["node", "serveronly"]
