ARG NODE_VERSION=8
# nodered stage
FROM node:${NODE_VERSION}

# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

#mosquitto directories
RUN mkdir -p /mqtt/config /mqtt/data /mqtt/log
# COPY mosquitto/config /mqtt/config



WORKDIR /usr/src/node-red

# Add node-red user so we aren't running as root.
# RUN useradd --home-dir /usr/src/node-red --no-create-home node-red \
#     && chown -R node-red:node-red /nrdata \
#     && chown -R node-red:node-red /usr/src/node-red


# #influxdb 
# curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
# source /etc/lsb-release
# echo "deb https://repos.influxdata.com/debian/ wheezy stable" | tee /etc/apt/sources.list.d/influxdb.list


# echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
# curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -

# #grafana
# echo "deb https://packagecloud.io/grafana/stable/debian/ wheezy main" | tee /etc/apt/sources.list.d/grafana.list
# curl https://packagecloud.io/gpg.key | apt-key add -

# wget https://dl.grafana.com/oss/release/grafana_6.3.5_amd64.deb
# sudo dpkg -i grafana_6.3.5_amd64.deb

RUN apt-get update && apt-get install apt-transport-https

#influxdb prerequisiter
COPY influxdb/influxdb.key.skr /root/
RUN cat /root/influxdb.key.skr | apt-key add -
# RUN curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
# RUN source /etc/lsb-release
RUN echo "deb https://repos.influxdata.com/debian/ stretch stable" | tee /etc/apt/sources.list.d/influxdb.list


RUN apt-get update && apt-get install -y mosquitto mosquitto-clients influxdb 
    # adduser --system --disabled-password --disabled-login mosquitto && \
    # useradd --home-dir /usr/src/node-red --no-create-home node-red \
    # && chown -R node-red:node-red /nrdata \
    # && chown -R node-red:node-red /usr/src/node-red \
    # && chown -R node-red:node-red /mqtt 
    # && adduser --system --disabled-password --disabled-login mosquitto

#grafana

RUN wget https://dl.grafana.com/oss/release/grafana_6.3.5_amd64.deb
RUN dpkg -i grafana_6.3.5_amd64.deb
#COPY grafana/grafana_6.3.5_amd64.deb /root/
#RUN dpkg -i /root/grafana_6.3.5_amd64.deb

# RUN apt-get clean autoclean \
# 	&& apt-get autoremove --yes \
# 	&& rm -rf /var/lib/{apt,dpkg,cache,log}

# USER mosquitto
# USER node-red



# COPY run.sh /usr/src/node-red/
# RUN chmod +x run.sh

#USER node-red

ENV TEST=other1-19
# package.json contains Node-RED NPM module and node dependencies
COPY nr/package.json /usr/src/node-red/
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
EXPOSE 1880 1883 9002 3000 8083 8086

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

COPY run.sh /root/
RUN chmod 7777 /root/run.sh

# CMD ["npm", "start", "--", "--userDir", "/nrdata"]
#CMD ["run.sh"]


VOLUME ["/mqtt", "/data", "/var/lib/grafana", "/var/lib/influxdb/"]


# ADD docker-entrypoint.sh /usr/bin/

# ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/root/run.sh"]

#docker exec -it final_nmgi1 bash
#docker build --rm -f "final/Dockerfile" -t nmgi:latest final