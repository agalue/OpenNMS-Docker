#!/bin/bash

# @author Alejandro Galue <agalue@opennms.org>

OPENNMS_HOME=/opt/minion
ONMS_ETC=$OPENNMS_HOME/etc
ONMS_BIN=$OPENNMS_HOME/bin

if [ ! -d ${OPENNMS_HOME} ]; then
  echo "OpenNMS home directory doesn't exist in ${OPENNMS_HOME}"
  exit
fi

cat <<EOF > $ONMS_ETC/org.opennms.netmgt.trapd.cfg
echo "trapd.listen.interface=0.0.0.0
trapd.listen.port=162
EOF

cat <<EOF > $ONMS_ETC/org.opennms.minion.controller.cfg
location = $location
id = $minion_id
http-url = $opennms_url
broker-url = $broker_url
EOF

echo hawtio-offline > $ONMS_ETC/featuresBoot.d/hawtio.boot

$ONMS_BIN/scvcli set opennms.http   $opennms_http_user   $opennms_http_passwd
$ONMS_BIN/scvcli set opennms.broker $opennms_broker_user $opennms_broker_passwd

/usr/sbin/haveged -w 1024

. $ONMS_BIN/inc
detectOS
locateHome
convertPaths
$ONMS_BIN/karaf server 2>&1

