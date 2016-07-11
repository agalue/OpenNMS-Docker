#!/bin/sh

docker run -d \
  -h postgres-server \
  --name postgres-server \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:latest
