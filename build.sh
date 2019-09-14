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

echo "Complete ${_docker_repo}:${_nmgi_version}"