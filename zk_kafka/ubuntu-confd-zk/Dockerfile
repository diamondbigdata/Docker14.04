FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV ZOO_VERSION=3.4.8 \
    ZOO_HOME=/opt/zk \ 
    ZOO_LOG_DIR=/opt/zk/logs \
    PATH=/opt/zk/bin:${PATH}
ENV ZOO_RELEASE=zookeeper-${ZOO_VERSION}
ADD zookeeper-3.4.8.tar /opt
RUN mv /opt/zookeeper-3.4.8 ${ZOO_HOME} \
  && mkdir -p ${ZOO_LOG_DIR} ${ZOO_HOME}/data \
  && chmod +x ${ZOO_HOME}/bin/zkServer.sh 
RUN echo "" > /opt/zk/logs/zookeeper.out

# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
RUN mkdir -p /opt/zk/logs
WORKDIR $ZOO_HOME
EXPOSE 2181 2888 3888
VOLUME ["/opt/zk/data"]
ENTRYPOINT ["/usr/bin/start.sh"]
