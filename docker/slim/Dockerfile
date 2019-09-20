ARG NODE_VERSION=8
# nodered stage
FROM node:${NODE_VERSION}-alpine




# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

#mosquitto directories
RUN mkdir -p /mqtt/config /mqtt/data /mqtt/log
# COPY mosquitto/config /mqtt/config



WORKDIR /usr/src/node-red

ENV INFLUXDB_VERSION 1.5.1
ENV GRAFANA_VERSION 5.0.4

# Influxdb
# https://github.com/influxdata/influxdata-docker/blob/master/influxdb/1.2/Dockerfile
RUN apk add --no-cache --virtual .build-deps wget gnupg tar ca-certificates && \
    update-ca-certificates && \
    gpg --keyserver hkp://ha.pool.sks-keyservers.net \
        --recv-keys 05CE15085FC09D18E99EFB22684A14CF2582E0C5 && \
    wget -q https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz.asc && \
    wget -q https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    gpg --batch --verify influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz.asc influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    mkdir -p /usr/src && \
    tar -C /usr/src -xzf influxdb-${INFLUXDB_VERSION}-static_linux_amd64.tar.gz && \
    rm -f /usr/src/influxdb-*/influxdb.conf && \
    chmod +x /usr/src/influxdb-*/* && \
    cp -a /usr/src/influxdb-*/* /usr/bin/ && \
    rm -rf *.tar.gz* /usr/src /root/.gnupg && \
    apk del .build-deps
VOLUME ["/etc/influxdb", "/var/lib/influxdb"]
EXPOSE 8083 8086

# Grafana
# https://github.com/orangesys/alpine-grafana/blob/master/4.2.0/Dockerfile
ENV GLIBC_VERSION=2.28-r0
ENV GOSU_VERSION=1.10
RUN set -ex \
 && addgroup -S grafana \
 && adduser -S -G grafana grafana \
 && apk add --no-cache ca-certificates openssl fontconfig bash curl \
 && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community dumb-init \
 && curl -sL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 > /usr/sbin/gosu \
 && chmod +x /usr/sbin/gosu  \
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk add glibc-${GLIBC_VERSION}.apk \
 && wget -q https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-$GRAFANA_VERSION.linux-x64.tar.gz \
 && tar -xzf grafana-$GRAFANA_VERSION.linux-x64.tar.gz \
 && mv grafana-$GRAFANA_VERSION/ grafana/ \
 && mv grafana/bin/* /usr/local/bin/ \
 && mkdir -p /grafana/data /grafana/data/plugins /var/lib/grafana/ \
 && ln -s /grafana/data/plugins /var/lib/grafana/plugins \
 && grafana-cli plugins update-all \
 && rm grafana-$GRAFANA_VERSION.linux-x64.tar.gz /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk \
 && chown -R grafana:grafana /grafana \
 && apk del curl
VOLUME ["/grafana"]
EXPOSE 3000


RUN apk update && apk add -y mosquitto mosquitto-clients 
    # adduser --system --disabled-password --disabled-login mosquitto && \
    # useradd --home-dir /usr/src/node-red --no-create-home node-red \
    # && chown -R node-red:node-red /nrdata \
    # && chown -R node-red:node-red /usr/src/node-red \
    # && chown -R node-red:node-red /mqtt 
    # && adduser --system --disabled-password --disabled-login mosquitto


# RUN apt-get clean autoclean \
# 	&& apt-get autoremove --yes \
# 	&& rm -rf /var/lib/{apt,dpkg,cache,log}

# USER mosquitto
# USER node-red



# COPY run.sh /usr/src/node-red/
# RUN chmod +x run.sh

#USER node-red

RUN apk add --no-cache python

ENV TEST=other1-20
# package.json contains Node-RED NPM module and node dependencies
COPY nr/package-slim.json /usr/src/node-red/
RUN npm install

# RUN chown -R mosquitto:mosquitto /mqtt
COPY mosquitto/config /mqtt/config
# RUN chown -R node-red:node-red /mqtt
RUN chown -R mosquitto:mosquitto /mqtt
#RUN chown -R 7777 /mqtt

# RUN chown -R node-red:node-red /usr/src/node-red


# VOLUME ["/mqtt/config", "/mqtt/data", "/mqtt/log", "/nrdata", "/var/lib/grafana", "/var/lib/influxdb/"]


# VOLUME ["/mqtt/", "/nrdata"]

# User configuration directory volume
EXPOSE 1880 1883 9002 8883

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning" \
    GF_INSTALL_PLUGINS="grafana-clock-panel,grafana-piechart-panel,grafana-simple-json-datasource  1.2.3"



#ADD docker-entrypoint.sh /usr/bin/
#ENTRYPOINT ["docker-entrypoint.sh"]

COPY influxdb/influxdb.conf /root/
RUN chmod 7777 /root/influxdb.conf

USER root

COPY grafana/preplugins.sh /root/
RUN chmod 7777 /root/preplugins.sh
RUN /root/preplugins.sh

ENV TEST=other24

COPY docker/run.sh /root/
RUN chmod 7777 /root/run.sh

# CMD ["npm", "start", "--", "--userDir", "/nrdata"]
#CMD ["run.sh"]

#zona de generacion de certificados por defecto
RUN mkdir /mqtt/certs
COPY mosquitto/generate-CA.sh /root
RUN chmod 7777 /root/generate-CA.sh
ENV TEST3=other1-
#buscar otro destino mejor para este fichero
RUN mkdir /root/mosquittoextras
COPY mosquitto/extraconf /root/mosquittoextras
# RUN chown -R node-red:node-red /mqtt
RUN chown -R mosquitto:mosquitto /root/mosquittoextras

# Other env if needed
#	IPLIST="172.13.14.15 192.168.1.1"
#	HOSTLIST="a.example.com b.example.com"
ENV TARGET=/mqtt/certs/ \
    CERTCA=ca \
    CERTCERT=default \
    CERTKEY=default
RUN /root/generate-CA.sh default


VOLUME ["/mqtt", "/data", "/mqtt/certs"], 


# ADD docker-entrypoint.sh /usr/bin/

# ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/root/run.sh"]

#docker exec -it final_nmgi1 bash
#docker build --rm -f "final/Dockerfile" -t nmgi:latest final