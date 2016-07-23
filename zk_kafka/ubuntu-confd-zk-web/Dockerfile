FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV ZW_VERSION=1.0 \
    ZW_HOME=/opt/zk-web \ 
    ZW_LOG_DIR=/opt/zk-web/logs 
ENV ZW_HTTP_PORT=8080
ENV ZW_USER=admin
ENV ZW_PASSWORD=admin
ENV ZK_DEFAULT_NODE=Kafka_zk_1
ENV LEIN_ROOT=/opt/zk-web
#add zk-web
ADD zk-web.tar /opt
RUN mkdir -p ${ZW_LOG_DIR}

#Install lein
RUN cd /usr/local/bin && \
		wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
		chmod +x /usr/local/bin/lein && \
		cd ${ZW_HOME} && \
		lein deps
RUN rm /opt/zk-web/conf/zk-web-conf.clj
# Add confd tmpl and toml
#ADD confd/*.toml /etc/confd/conf.d/
#ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
#ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
WORKDIR $ZW_HOME
EXPOSE 8080
ENTRYPOINT ["/usr/bin/start.sh"]
