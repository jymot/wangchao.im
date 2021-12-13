#!/usr/bin/env bash

serviceName=wangchao.im
VIRTUAL_HOST=wangchao.im
VIRTUAL_PORT=80

docker pull docker-registry.wangchao.im/jy/wangchao.im:0.1.0
docker ps -q --filter name="${serviceName}" | xargs -r docker rm -f
docker run -d --name ${serviceName} --restart always \
    --network ingot-net \
    -e VIRTUAL_HOST=${VIRTUAL_HOST} \
    -e VIRTUAL_PORT=${VIRTUAL_PORT} \
    -e LETSENCRYPT_HOST=${VIRTUAL_HOST} \
    docker-registry.wangchao.im/jy/wangchao.im:0.1.0