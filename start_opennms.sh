#!/bin/sh

docker run -d \
  -h opennms-server \
  --name opennms-server \
  --link postgres-server \
  --privileged \
  -e POSTGRES_HOST=postgres-server \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_PASSWORD=postgres \
  -p 8981:8980 \
  agalue/opennms
