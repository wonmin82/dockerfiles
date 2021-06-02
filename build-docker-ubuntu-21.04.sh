#! /usr/bin/env bash

set -e +x

ssh_port=11022

unset ssh_prv_key
unset ssh_pub_key
unset gitconfig

[ -f ~/.ssh/id_rsa ] && ssh_prv_key=$(cat ~/.ssh/id_rsa)
[ -f ~/.ssh/id_rsa.pub ] && ssh_pub_key=$(cat ~/.ssh/id_rsa.pub)
[ -f ~/.gitconfig ] && gitconfig=$(cat ~/.gitconfig)

docker build \
	-t docker-ubuntu-21.04 \
	--build-arg user="${USER}" \
	--build-arg uid="$(id -u)" \
	--build-arg gid="$(id -g)" \
	--build-arg ssh_prv_key="${ssh_prv_key}" \
	--build-arg ssh_pub_key="${ssh_pub_key}" \
	--build-arg gitconfig="${gitconfig}" \
	$PWD/docker-ubuntu-21.04
docker run \
	--detach \
	--restart unless-stopped \
	--publish=${ssh_port}:22 \
	--hostname=docker-ubuntu-hirsute \
	--name=docker-ubuntu-21.04 \
	docker-ubuntu-21.04
docker stop \
	docker-ubuntu-21.04
docker tag \
	docker-ubuntu-21.04 \
	docker-ubuntu-21.04:latest
