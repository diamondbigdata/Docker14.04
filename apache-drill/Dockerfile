FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV DRILL_VERSION=1.7.0 \
    DRILL_HOME=/opt/drill \ 
    DRILL_LOG_DIR=/opt/drill/logs \
    PATH=/opt/drill/bin:${PATH}
ENV DRILL_RELEASE=apache-drill-${DRILL_VERSION}a
ENV DRILL_CLUSTER=drillCluster
ENV DRILL_HEAP=4G
ENV DRILL_MAX_DIRECT_MEMORY=8G
ENV ZK_SERVICE=Kafka/zk
ADD apache-drill-1.7.0.tar /opt
RUN mv /opt/apache-drill-1.7.0 ${DRILL_HOME} \
  && mkdir -p ${DRILL_LOG_DIR} ${DRILL_HOME}/data \
  && chmod +x ${DRILL_HOME}/bin/drillbit.sh

# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
WORKDIR $DRILL_HOME
EXPOSE 22 8047
VOLUME ["/opt/drill/data"]
ENTRYPOINT ["/usr/bin/start.sh"]
