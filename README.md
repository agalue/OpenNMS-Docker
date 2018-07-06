# OpenNMS-Docker

To build the container:

```shell
cd opennms
docker build -t agalue/opennms-ui:22.0.1 .
```

This container is already available at Docker Hub, [here](https://hub.docker.com/r/agalue/opennms/).

To run the container, keep in mind that it depends on having a container with PostgreSQL up and running, based on the [Official postgres image](https://hub.docker.com/_/postgres/)

Manual Start
==============

To Start PostgreSQL use the `postgresql_start.sh` script (PostgreSQL will be exposed on port 5432).
To Start OpenNMS use the `opennms_start.sh` script (OpenNMS WebUI will be exposed on port 8980).

Automatic Start
===============

From the directory on which you have `docker-compose.yml`:

```shell
docker-compose up
```

Kubernetes Start
===============

There are 3 different examples to deploy OpenNMS in kubernetes.

```shell
cd opennms/kubernetes
kubectl create -f onms-and-pg-deployments.yaml
```
