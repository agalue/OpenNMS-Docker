FROM centos
MAINTAINER agalue@opennms.org

RUN yum -y install https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm \
 && yum -y install http://yum.opennms.org/repofiles/opennms-repo-stable-rhel7.noarch.rpm \
 && yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm \
 && yum -y install postgresql95 haveged rrdtool jrrd2 jicmp jicmp6 opennms-core opennms-webapp-jetty \
 && yum clean all

COPY opennms-datasources.xml /opt/opennms/etc/
COPY bootstrap.sh /opt/opennms/bin/
RUN chmod +x /opt/opennms/bin/bootstrap.sh
EXPOSE 8980 8443 5817 8101

CMD ["/opt/opennms/bin/bootstrap.sh"]

VOLUME ["/opt/opennms/etc","/var/opennnms","/var/log/opennms"]
