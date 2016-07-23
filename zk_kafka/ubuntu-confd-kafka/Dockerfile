FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV KAFKA_HOME=/opt/kafka \
    SERVICE_NAME=kafka \
    SCALA_VERSION=2.11 \
    KAFKA_VERSION=0.9.0.1
ENV KAFKA_RELEASE=kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"  
ENV ZK_SERVICE=Kafka/zk
# Install and configure kafka
#RUN curl -sS -k http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/"$KAFKA_RELEASE".tgz | gunzip -c - | tar -xf - -C /opt \
ADD kafka_2.11-0.9.0.1.tar /opt
RUN ln -s /opt/${KAFKA_RELEASE} ${KAFKA_HOME} \
  && cd ${KAFKA_HOME}/libs/ \
  && mkdir ${KAFKA_HOME}/data ${KAFKA_HOME}/logs 
RUN ls -l ${KAFKA_HOME}
RUN echo "" > /opt/kafka/logs/kafkaServer.out
# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start and restart scripts
ADD kafka-server-restart.sh /opt/kafka/bin/kafka-server-restart.sh
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh /opt/kafka/bin/kafka-server-restart.sh

WORKDIR ${KAFKA_HOME}
EXPOSE 9092
VOLUME ["/opt/kafka/data"]
ENTRYPOINT ["/usr/bin/start.sh"]
