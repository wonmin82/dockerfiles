#! /usr/bin/env bash

set -e -x

docker build -t docker-ubuntu-19.04 $PWD/docker-ubuntu-19.04
docker run --detach --publish=21904:22 --hostname=docker-ubuntu-disco --name=docker-ubuntu-19.04 docker-ubuntu-19.04
docker stop docker-ubuntu-19.04
docker commit -m "Initial Ubuntu 19.04" docker-ubuntu-19.04 docker-ubuntu-19.04:initial
