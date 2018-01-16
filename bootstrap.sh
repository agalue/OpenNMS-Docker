#!/bin/bash

# @author Alejandro Galue <agalue@opennms.org>
# Tested on Horizon 17.1.1, and newer

OPENNMS_HOME=/opt/opennms
ONMS_ETC=$OPENNMS_HOME/etc
ONMS_BIN=$OPENNMS_HOME/bin
PG_BIN=/usr/pgsql-9.6/bin

if [ ! -d ${OPENNMS_HOME} ]; then
  echo "OpenNMS home directory doesn't exist in ${OPENNMS_HOME}"
  exit
fi

# Configure PostgreSQL
cat <<EOF > $ONMS_ETC/opennms-datasources.xml
<?xml version="1.0" encoding="UTF-8"?>
<datasource-configuration xmlns:this="http://xmlns.opennms.org/xsd/config/opennms-datasources"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.opennms.org/xsd/config/opennms-datasources
  http://www.opennms.org/xsd/config/opennms-datasources.xsd ">

  <connection-pool factory="org.opennms.core.db.HikariCPConnectionFactory"
    idleTimeout="600"
    loginTimeout="3"
    minPool="50"
    maxPool="50"
    maxSize="50" />

  <jdbc-data-source name="opennms"
                    database-name="opennms"
                    class-name="org.postgresql.Driver"
                    url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/opennms"
                    user-name="opennms"
                    password="opennms">
    <param name="connectionTimeout" value="0"/>
  </jdbc-data-source>

  <jdbc-data-source name="opennms-admin"
                    database-name="template1"
                    class-name="org.postgresql.Driver"
                    url="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/template1"
                    user-name="postgres"
                    password="$POSTGRES_PASSWORD" />
</datasource-configuration>
EOF

# Expose the Karaf shell
sed -i "s/sshHost.*/sshHost=0.0.0.0/g" $ONMS_ETC/org.apache.karaf.shell.cfg

# Expose Event TCP Interface
sed -i "s/127.0.0.1/0.0.0.0/g" $ONMS_ETC/eventd-configuration.xml

# Configuring JRRD2 Strategy
sed -i "/MultithreadedJniRrdStrategy/s/#//" $ONMS_ETC/rrd-configuration.properties
sed -i "/jrrd2/s/#//" $ONMS_ETC/rrd-configuration.properties

# Enable storeByGroup and storeByFS
sed -i "/rrd.storeBy/s/false/true/" $ONMS_ETC/opennms.properties

# Start haveged (to reduce the startup time of OpenNMS)
/usr/sbin/haveged -w 1024

# Create pgpass
echo "*:*:*:postgres:$POSTGRES_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass

# Wait for PostgreSQL
until $PG_BIN/psql -h "$POSTGRES_HOST" -p $POSTGRES_PORT -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
>&2 echo "Postgres is up - starting opennms"

# Initialize OpenNMS
if [ ! -f $ONMS_ETC/java.conf ]; then
  $ONMS_BIN/runjava -s
fi
if [ ! -f $ONMS_ETC/configured ]; then
  $ONMS_BIN/install -dis
fi

# Start OpenNMS
$ONMS_BIN/opennms -f start
