#!/bin/bash

set -e -x

docker build -t wonmin82-xenial $PWD/wonmin82-xenial
docker run --detach --publish=30022:22 --hostname=wonmin82-xenial-docker --name=wonmin82-xenial-docker wonmin82-xenial
docker stop wonmin82-xenial-docker
