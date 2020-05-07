#! /usr/bin/env bash

set -e +x

docker build                                           \
	-t docker-ubuntu-20.04                             \
	--build-arg user="${USER}"                         \
	--build-arg uid="$(id -u)"                         \
	--build-arg gid="$(id -g)"                         \
	--build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)"     \
	--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" \
	$PWD/docker-ubuntu-20.04
docker run                                             \
	--detach                                           \
	--ulimit memlock=67108864                          \
	--publish=22004:22                                 \
	--hostname=docker-ubuntu-focal                     \
	--name=docker-ubuntu-20.04                         \
	docker-ubuntu-20.04
docker stop                                            \
	docker-ubuntu-20.04
docker tag                                             \
	docker-ubuntu-20.04                                \
	docker-ubuntu-20.04:latest
