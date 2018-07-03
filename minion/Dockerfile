FROM centos:7
MAINTAINER agalue@opennms.org

ENV location Docker
ENV minion_id 001
ENV opennms_url http://localhost:8980/opennms
ENV broker_url failover:tcp://localhost:61616
ENV opennms_http_user minion
ENV opennms_http_passwd minion
ENV opennms_broker_user minion
ENV opennms_broker_passwd minion

WORKDIR /opt/minion

COPY bootstrap-minion.sh /tmp

RUN yum -y install http://yum.opennms.org/repofiles/opennms-repo-stable-rhel7.noarch.rpm \
 && yum -y install epel-release \
 && yum -y install haveged \
 && yum -y install opennms-minion \
 && yum clean all \
 && cp /tmp/bootstrap.sh bin \
 && chmod +x bin/bootstrap.sh

EXPOSE 8201 162

CMD ["bin/bootstrap.sh"]

VOLUME ["etc"]
