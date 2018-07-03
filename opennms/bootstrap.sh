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

# Configure PostgreSQL Database
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

# Simplify Eventd configuration for a UI server
cat <<EOF > $ONMS_ETC/eventconf.xml
<?xml version="1.0"?>
<events xmlns="http://xmlns.opennms.org/xsd/eventconf">
  <global>
    <security>
      <doNotOverride>logmsg</doNotOverride>
      <doNotOverride>operaction</doNotOverride>
      <doNotOverride>autoaction</doNotOverride>
      <doNotOverride>tticket</doNotOverride>
      <doNotOverride>script</doNotOverride>
    </security>
  </global>
  <event-file>events/opennms.ackd.events.xml</event-file>
  <event-file>events/opennms.alarm.events.xml</event-file>
  <event-file>events/opennms.alarmChangeNotifier.events.xml</event-file>
  <event-file>events/opennms.bsm.events.xml</event-file>
  <event-file>events/opennms.capsd.events.xml</event-file>
  <event-file>events/opennms.config.events.xml</event-file>
  <event-file>events/opennms.correlation.events.xml</event-file>
  <event-file>events/opennms.default.threshold.events.xml</event-file>
  <event-file>events/opennms.discovery.events.xml</event-file>
  <event-file>events/opennms.internal.events.xml</event-file>
  <event-file>events/opennms.linkd.events.xml</event-file>
  <event-file>events/opennms.mib.events.xml</event-file>
  <event-file>events/opennms.ncs-component.events.xml</event-file>
  <event-file>events/opennms.pollerd.events.xml</event-file>
  <event-file>events/opennms.provisioning.events.xml</event-file>
  <event-file>events/opennms.minion.events.xml</event-file>
  <event-file>events/opennms.remote.poller.events.xml</event-file>
  <event-file>events/opennms.reportd.events.xml</event-file>
  <event-file>events/opennms.syslogd.events.xml</event-file>
  <event-file>events/opennms.ticketd.events.xml</event-file>
  <event-file>events/opennms.tl1d.events.xml</event-file>
  <event-file>events/opennms.catch-all.events.xml</event-file>
</events>
EOF

# WebUI Services
cat <<EOF > $ONMS_ETC/service-configuration.xml
<?xml version="1.0"?>
<service-configuration xmlns="http://xmlns.opennms.org/xsd/config/vmmgr">
  <service>
    <name>OpenNMS:Name=Manager</name>
    <class-name>org.opennms.netmgt.vmmgr.Manager</class-name>
    <invoke at="stop" pass="1" method="doSystemExit"/>
  </service>
  <service>
    <name>OpenNMS:Name=TestLoadLibraries</name>
    <class-name>org.opennms.netmgt.vmmgr.Manager</class-name>
    <invoke at="start" pass="0" method="doTestLoadLibraries"/>
  </service>
  <service>
    <name>OpenNMS:Name=Eventd</name>
    <class-name>org.opennms.netmgt.eventd.jmx.Eventd</class-name>
    <invoke at="start" pass="0" method="init"/>
    <invoke at="start" pass="1" method="start"/>
    <invoke at="status" pass="0" method="status"/>
    <invoke at="stop" pass="0" method="stop"/>
  </service>
  <service>
    <name>OpenNMS:Name=JettyServer</name>
    <class-name>org.opennms.netmgt.jetty.jmx.JettyServer</class-name>
    <invoke at="start" pass="0" method="init"/>
    <invoke at="start" pass="1" method="start"/>
    <invoke at="status" pass="0" method="status"/>
    <invoke at="stop" pass="0" method="stop"/>
  </service>
</service-configuration>
EOF

# WebUI Settings
cat <<EOF >> $ONMS_ETC/opennms.properties.d/webui.properties
org.opennms.web.console.centerUrl=/status/status-box.jsp,/geomap/map-box.jsp,/heatmap/heatmap-box.jsp
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

# Enable CORS
WEB_XML=$OPENNMS_HOME/jetty-webapps/opennms/WEB-INF/web.xml
sed -r -i '/[<][!]--/{$!{N;s/[<][!]--\n  ([<]filter-mapping)/\1/}}' $WEB_XML
sed -r -i '/nrt/{$!{N;N;s/(nrt.*\n  [<]\/filter-mapping[>])\n  --[>]/\1/}}' $WEB_XML

# Forcing OpenNMS to be read-only in terms of administrative changes
SEC_CFG=$OPENNMS_HOME/jetty-webapps/opennms/WEB-INF/applicationContext-spring-security.xml
sed -r -i 's/ROLE_ADMIN/ROLE_DISABLED/' $SEC_CFG
sed -r -i 's/ROLE_PROVISION/ROLE_DISABLED/' $SEC_CFG

# Start haveged (to reduce the startup time of OpenNMS)
/usr/sbin/haveged -w 1024

# Create pgpass
echo "*:*:*:postgres:$POSTGRES_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass

# Wait for PostgreSQL
while ! pg_isready -h "$POSTGRES_HOST" -p $POSTGRES_PORT 
do
  echo "$(date) - waiting for database to start"
  sleep 5
done

# Initialize OpenNMS
if [ ! -f $ONMS_ETC/java.conf ]; then
  $ONMS_BIN/runjava -s
fi
touch $ONMS_ETC/configured
#if [ ! -f $ONMS_ETC/configured ]; then
#  $ONMS_BIN/install -dis
#fi

# Start OpenNMS
$ONMS_BIN/opennms -f start
