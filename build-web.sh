#!/usr/bin/env bash

npm run build

docker build -t docker-registry.wangchao.im/jy/wangchao.im:0.1.0 .

docker push docker-registry.wangchao.im/jy/wangchao.im:0.1.0