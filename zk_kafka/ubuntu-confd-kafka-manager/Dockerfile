FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Set environment
ENV KM_HOME=/opt/kafka-manager \
    application.home=/opt/kafka-manager \
    SERVICE_NAME=kafka-manager \
    KM_VERSION=1.3.0.8
RUN mkdir -p /tmp
ADD kafka-manager-1.3.0.8.tar /opt
RUN ln -s /opt/kafka-manager-1.3.0.8 ${KM_HOME}
WORKDIR ${KM_HOME}
# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start and restart scripts
ADD restartkm.sh /opt/kafka-manager/bin/restartkm.sh
ADD stopkm.sh /opt/kafka-manager/bin/stopkm.sh 
ADD start.sh /usr/bin/start.sh
ADD startkm.sh /opt/kafka-manager/bin/startkm.sh
RUN chmod +x /usr/bin/start.sh /opt/kafka-manager/bin/restartkm.sh /opt/kafka-manager/bin/stopkm.sh /opt/kafka-manager/bin/startkm.sh
EXPOSE 9000
ENTRYPOINT ["/usr/bin/start.sh"]
