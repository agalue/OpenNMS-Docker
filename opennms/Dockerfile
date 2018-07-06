FROM centos:7
MAINTAINER agalue@opennms.org

ARG onms_repo=stable

WORKDIR /opt/opennms

COPY bootstrap.sh /tmp

RUN groupadd -r opennms \
 && useradd -r -g opennms -d /opt/opennms -s /sbin/nologin -c 'OpenNMS User' opennms \
 && yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm \
 && yum -y install http://yum.opennms.org/repofiles/opennms-repo-$onms_repo-rhel7.noarch.rpm \
 && yum -y install epel-release \
 && yum -y install java-1.8.0-openjdk-devel postgresql96 haveged rrdtool jrrd2 jicmp jicmp6 opennms-core opennms-webapp-jetty \
 && yum clean all \
 && chown -R opennms:opennms /opt/opennms /var/opennms /var/log/opennms \
 && sed -r -i '/^RUNAS/s/root/opennms/' /opt/opennms/bin/install \
 && sed -r -i '/^RUNAS/s/root/opennms/' /opt/opennms/bin/opennms \
 && cp /tmp/bootstrap.sh bin \
 && chmod +x bin/bootstrap.sh

USER opennms

EXPOSE 8980 5817 8101 162

CMD ["bin/bootstrap.sh"]

VOLUME ["etc","share","logs"]
