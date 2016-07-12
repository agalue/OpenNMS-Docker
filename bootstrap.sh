#!/bin/bash

# @author Alejandro Galue <agalue@opennms.org>
# Tested on Horizon 17.1.1, and newer

OPENNMS_HOME=/opt/opennms
ONMS_ETC=$OPENNMS_HOME/etc
ONMS_BIN=$OPENNMS_HOME/bin

if [ ! -d ${OPENNMS_HOME} ]; then
  echo "OpenNMS home directory doesn't exist in ${OPENNMS_HOME}"
  exit
fi

# Configure PostgreSQL connections
sed -i s/PG_HOST/$(echo $POSTGRES_HOST)/g $ONMS_ETC/opennms-datasources.xml
sed -i s/PG_PORT/$(echo $POSTGRES_PORT)/g $ONMS_ETC/opennms-datasources.xml
sed -i s/PG_PASSWORD/$(echo $POSTGRES_PASSWORD)/g $ONMS_ETC/opennms-datasources.xml

# Expose the Karaf shell
sed -i "s/sshHost.*/sshHost=0.0.0.0/g" $ONMS_ETC/org.apache.karaf.shell.cfg

# Configuring JRRD2 Strategy
sed -i "/MultithreadedJniRrdStrategy/s/#//" $ONMS_ETC/rrd-configuration.properties
sed -i "/jrrd2/s/#//" $ONMS_ETC/rrd-configuration.properties

# Enable storeByGroup and storeByFS
sed -i "/rrd.storeBy/s/false/true/" $ONMS_ETC/opennms.properties

# Initialize and start OpenNMS
/usr/sbin/haveged -w 1024
if [ ! -f $ONMS_ETC/java.conf ]; then
  $ONMS_BIN/runjava -s
fi
if [ ! -f $ONMS_ETC/configured ]; then
  $ONMS_BIN/install -dis
fi
$ONMS_BIN/opennms -f start
