#THIS DOCKERFILE IS OPTIMIZED TO Raspberry pi 4 and Raspbian ARM64 (aarch64) platform
FROM node:16-bullseye-slim
LABEL maintainer="cslev <cslev@gmx.com>"
#ARG branch=master

ENV DEPS gettext \
         git \
         net-tools \ 
         ethtool \
         dnsutils \
         nano \
         ca-certificates \
         bash \
         iputils-ping \
         #these three below are required to compile lol_dht22 for DHT22 sensor
         gcc \
         make \
         automake-1.15 \
         sudo 
#         wget 
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
    #wiringPi - only for armhf/raspberry pi arch 32-bit`
#    wget https://project-downloads.drogon.net/wiringpi-latest.deb;\
#    DEBIAN_FRONTEND=noninteractive dpkg -i wiringpi-latest.deb;\
    #lol_dht22 is needed for aarch64, pure wiringpi+dht_var do not work
    git clone https://github.com/guation/WiringPi-arm64.git; \
    cd WiringPi-arm64/; \
    ./build;\
    cd ..;\
    git clone https://github.com/technion/lol_dht22; \
    cd lol_dht22;\
    ./configure;\
    make;\
    #cleaning
    DEBIAN_FRONTEND=noninteractive apt-get remove -y gcc make automake-1.15 git; \
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
