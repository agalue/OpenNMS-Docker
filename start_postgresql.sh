#!/bin/sh

docker run -d \
  -h postgresql-server \
  --name postgresql-server \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -v opennms_db:/var/lib/postgresql/data \
  postgres:9
