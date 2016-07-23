FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV SPARK_VERSION=1.6.2 \
    HADOOP_VERSION=2.6 \
    SPARK_HOME=/opt/spark \
    SPARK_LOG_DIR=/opt/spark/logs \
    SCALA_VERSION=2.10.6 \
    PATH=/usr/lib/scala/scala-2.10.6/bin:/opt/spark/bin:${PATH}
ENV SPARK_RELEASE=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

#for start.sh & slaves SPARK_ROLE=master|worker
ENV SPARK_ROLE=master
ENV SPARK_IP=sparkmaster
ENV SPARK_WORKER_HOSTNAME=sparkworker

#for spark-env.sh
ENV SPARK_MASTER_IP=sparkmaster
ENV SPARK_MASTER_PORT=7077
ENV SPARK_MASTER_WEBUI_PORT=8080
ENV SPARK_MASTER_OPTS=""
ENV SPARK_WORKER_CORES=4
ENV SPARK_WORKER_MEMORY=1g
ENV SPARK_WORKER_WEBUI_PORT=8081
ENV SPARK_EXECUTOR_INSTANCES=1
ENV SPARK_WORKER_DIR=/opt/spark/work
ENV SPARK_WORKER_OPTS=""
ENV SPARK_DAEMON_MEMORY=1g
ENV SPARK_HISTORY_OPTS=""
ENV SPARK_SHUFFLE_OPTS=""
ENV SPARK_DAEMON_JAVA_OPTS=""

#for spark-defaults.conf
ENV SPARK_EVENTlOG_ENABLED=false
ENV SPARK_EVENTlOG_DIR=/tmp/sparkeventlog
ENV SPARK_SERIALIZER=org.apache.spark.serializer.KryoSerializer
ENV SPARK_DRIVER_MEMORY=1g
ENV SPARK_EXECUTOR_EXTRAJAVAOPTIONS=""

#add spark & scala
ADD ${SPARK_RELEASE}.tar /opt
RUN ln -s /opt/${SPARK_RELEASE} ${SPARK_HOME} \
  && mkdir -p ${SPARK_LOG_DIR}
  
RUN mkdir -p /usr/lib/scala
ADD scala-2.10.6.tar /usr/lib/scala

# Add confd tmpl and toml
#ADD confd/*.toml /etc/confd/conf.d/
#ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
#ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
WORKDIR $SPARK_HOME
EXPOSE 8080 7077 6066 8081
VOLUME ["/opt/spark/conf"] 
ENTRYPOINT ["/usr/bin/start.sh"] 
