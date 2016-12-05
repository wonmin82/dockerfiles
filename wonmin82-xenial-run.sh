#!/bin/bash

set -e -x

docker run --detach --publish=10022:22 --hostname=wonmin82-xenial-docker --name=wonmin82-xenial-docker wonmin82-xenial
