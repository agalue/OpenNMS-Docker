#!/bin/sh

docker run -d \
  -h opennms-server \
  --name opennms-server \
  --link postgresql-server \
  -e POSTGRES_HOST=postgresql-server \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_PASSWORD=postgres \
  -v opennms_etc:/opt/opennms/etc \
  -v opennms_share:/opt/opennms/share \
  -v opennms_logs:/opt/opennms/logs \
  -p 8980:8980 \
  agalue/opennms-ui
