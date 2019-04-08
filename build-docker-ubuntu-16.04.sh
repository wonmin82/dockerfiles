#! /usr/bin/env bash

set -e -x

docker build                        \
	-t docker-ubuntu-16.04          \
	--build-arg user=${USER}        \
	$PWD/docker-ubuntu-16.04
docker run                          \
	--detach                        \
	--publish=21604:22              \
	--hostname=docker-ubuntu-xenial \
	--name=docker-ubuntu-16.04      \
	docker-ubuntu-16.04
docker stop                         \
	docker-ubuntu-16.04
docker commit                       \
	-m "Initial Ubuntu 16.04"       \
	docker-ubuntu-16.04             \
	docker-ubuntu-16.04:initial
