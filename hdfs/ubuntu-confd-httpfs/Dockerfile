FROM diamondreg:5000/ubuntu-confd-hdfs:2.7.2
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Setup env
USER root
ENV HDPRole jnode 
ENV HDP_START_TIMEWAIT 10


#Ports: WebHDFS
EXPOSE 14000

# Copy the bootstrap shell
# Copy the bootstrap shell
RUN rm /opt/hadoop/etc/hadoop/httpfs-site.xml && rm /opt/hadoop/bin/starthdp.sh && rm /opt/hadoop/bin/stophdp.sh && rm /opt/hadoop/bin/restarthdp.sh
COPY httpfs-site.xml /opt/hadoop/etc/hadoop/httpfs-site.xml
ADD starthttpfs.sh /opt/hadoop/bin/
ADD stophttpfs.sh /opt/hadoop/bin/
ADD restarthttpfs.sh /opt/hadoop/bin/
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh && chmod +x /opt/hadoop/bin/starthttpfs.sh && chmod +x /opt/hadoop/bin/stophttpfs.sh && chmod +x /opt/hadoop/bin/restarthttpfs.sh

ENTRYPOINT ["/usr/bin/start.sh"]
