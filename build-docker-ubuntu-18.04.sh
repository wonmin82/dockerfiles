#! /usr/bin/env bash

set -e +x

ssh_port=13022

docker build \
	-t docker-ubuntu-18.04 \
	--build-arg user="${USER}" \
	--build-arg uid="$(id -u)" \
	--build-arg gid="$(id -g)" \
	--build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" \
	--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" \
	$PWD/docker-ubuntu-18.04
docker run \
	--detach \
	--restart unless-stopped \
	--publish=${ssh_port}:22 \
	--hostname=docker-ubuntu-bionic \
	--name=docker-ubuntu-18.04 \
	docker-ubuntu-18.04
docker stop \
	docker-ubuntu-18.04
docker tag \
	docker-ubuntu-18.04 \
	docker-ubuntu-18.04:latest
