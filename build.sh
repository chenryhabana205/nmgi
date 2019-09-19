#!/bin/sh

_nmgi_tag=$1
_repo=chenryhabana205

# If the tag starts with v, treat this as a official release
if echo "$_nmgi_tag" | grep -q "^v"; then
	_nmgi_version=$(echo "${_nmgi_tag}" | cut -d "v" -f 2)
	_docker_repo=${2:-$_repo/nmgi}
else
	_nmgi_version=$_nmgi_tag
	_docker_repo=${2:-nmgi-dev}
fi


echo "Building ${_docker_repo}:${_nmgi_version}"

#run from scrash
# docker build \
# 	--tag "${_docker_repo}:${_nmgi_version}" \
# 	--no-cache=true .

docker build \
	--tag "${_docker_repo}:${_nmgi_version}" .

# Tag as 'latest' for official release; otherwise tag as grafana/grafana:master
if echo "$_nmgi_tag" | grep -q "^v"; then
	docker tag "${_docker_repo}:${_nmgi_version}" "${_docker_repo}:latest"
else
	docker tag "${_docker_repo}:${_nmgi_version}" "nmgi:master"
fi

echo "Building docker composer file"

echo "
version: '3'
services:
  nmgi:
    image: ${_docker_repo}:${_nmgi_version}
    # privileged added so usb drive can be mounted.
    privileged: true
    ports:
      - \"1880:1880\"
      - \"1883:1883\"
      - \"9002:9002\"
      - \"3000:3000\"
      - \"8083:8083\"
      - \"8086:8086\"
      - \"8883:8883\"
    environment:
      TOTHER2: value
      # MOSQUITTOCA: 1
      GF_INSTALL_PLUGINS: null
      # GF_INSTALL_PLUGINS: grafana-clock-panel,grafana-piechart-panel,grafana-simple-json-datasource  1.2.3
    volumes:
      # - ./data/mqtt:/mqtt/
      # - ./data/mqtt/data:/mqtt/data
      # - ./data/mqtt/log:/mqtt/log
      - ./data/nrdata:/data
      - ./data/grafana:/var/lib/grafana
      - ./data/influxdb:/var/lib/influxdb
    " > docker-compose.yml

echo "Complete ${_docker_repo}:${_nmgi_version}"