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

# Configuring RRD Strategy
sed -i "s/#org.opennms.rrd.strategyClass=.*MultithreadedJniRrdStrategy/org.opennms.rrd.strategyClass=org.opennms.netmgt.rrd.rrdtool.MultithreadedJniRrdStrategy/" $ONMS_ETC/rrd-configuration.properties
sed -i "s/#opennms.library.jrrd2/opennms.library.jrrd2/" $ONMS_ETC/rrd-configuration.properties
sed -i "s/#org.opennms.rrd.interfaceJar/org.opennms.rrd.interfaceJar/" $ONMS_ETC/rrd-configuration.properties
sed -i "s/org.opennms.rrd.storeByGroup=.*/org.opennms.rrd.storeByGroup=true/" $ONMS_ETC/opennms.properties
sed -i "s/org.opennms.rrd.storeByForeignSource=.*/org.opennms.rrd.storeByForeignSource=true/" $ONMS_ETC/opennms.properties

# Initialize and start OpenNMS
/usr/sbin/haveged -w 1024
$ONMS_BIN/runjava -s
$ONMS_BIN/install -dis
$ONMS_BIN/opennms -f start
