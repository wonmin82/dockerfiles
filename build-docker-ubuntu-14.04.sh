#!/bin/bash

set -e -x

docker build -t docker-ubuntu-14.04 $PWD/docker-ubuntu-14.04
docker run --detach --publish=21404:22 --hostname=docker-ubuntu-14.04 --name=docker-ubuntu-14.04 ubuntu-14.04
docker stop docker-ubuntu-14.04
