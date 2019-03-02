#!/bin/bash

set -e -x

docker build -t wonmin82-zesty $PWD/wonmin82-zesty
docker run --detach --publish=21704:22 --hostname=wonmin82-zesty-docker --name=wonmin82-zesty-docker wonmin82-zesty
docker stop wonmin82-zesty-docker
