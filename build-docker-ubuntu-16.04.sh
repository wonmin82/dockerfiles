#! /usr/bin/env bash

set -e +x

ssh_port=14022

docker build \
	-t docker-ubuntu-16.04 \
	--build-arg user="${USER}" \
	--build-arg uid="$(id -u)" \
	--build-arg gid="$(id -g)" \
	--build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" \
	--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" \
	$PWD/docker-ubuntu-16.04
docker run \
	--detach \
	--restart unless-stopped \
	--publish=${ssh_port}:22 \
	--hostname=docker-ubuntu-xenial \
	--name=docker-ubuntu-16.04 \
	docker-ubuntu-16.04
docker stop \
	docker-ubuntu-16.04
docker tag \
	docker-ubuntu-16.04 \
	docker-ubuntu-16.04:latest
