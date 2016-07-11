# OpenNMS-Docker

To build the container:

```
docker build -t agalue/opennms:latest .
```

This container is already available at Docker Hub, [here](https://hub.docker.com/r/agalue/opennms/).

To run the container, keep in mind that it depends on having a container with PostgreSQL up and running, based on the [Official postgres image](https://hub.docker.com/_/postgres/)

To Start PostgreSQL use the `postgresql_start.sh` script (PostgreSQL will be exposed on port 5433).
To Start OpenNMS use the `opennms_start.sh` script (OpenNMS WebUI will be exposed on port 8981).

NOTE: The reason I have --privileged on opennms_start.sh is due to NMS-8200. On future versions of OpenNMS, this might not be required.
