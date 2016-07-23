FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

# Setup env
USER root
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV HADOOP_PREFIX /opt/hadoop
ENV HADOOP_COMMON_HOME /opt/hadoop
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop

ENV HDPRole jnode
ENV HDPClusterName DiamondHDP
ENV HDP_START_TIMEWAIT 10
ENV ZK_SERVICE Kafka/zk
ENV PNode_SERVICE HDP/pnode
ENV SNode_SERVICE HDP/snode
ENV JNode_SERVICE HDP/jnode
ENV PNode_SERVICE_HostName PNameNode
ENV SNode_SERVICE_HostName SNameNode
ENV HADOOP_HDFS_NAMENODE /data/hdfs/namenode
ENV HADOOP_HDFS_JOURNALNODE /data/hdfs/journal
ENV HADOOP_HDFS_DATANODE /data/hdfs/datanode 

# download hadoop
ADD hadoop-2.7.2.tar /opt
RUN mv /opt/hadoop-2.7.2 /opt/hadoop \
 && mkdir -p /data/hdfs/namenode \
 && mkdir -p /data/hdfs/datanode \
 && mkdir -p /data/hdfs/journal \
 && mkdir -p /opt/hadoop/logs \
 && chown -R root:root /opt/hadoop \
 && chmod -R 755 /opt/hadoop

# Copy the Site files up
# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/ 

#Clean
RUN apt-get purge -y --auto-remove
RUN sudo rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hadoop

#Ports: SSH Namenode                         DataNode                          Journal Node WebHDFS
EXPOSE 22 8020 8022 50070 50470 50090 50495 1006 1004 50010 50020 50075 50475 8485 8480 14000

# Location to store data
VOLUME ["/data/hdfs/datanode", "/data/hdfs/journal", "/data/hdfs/namenode", "/opt/hadoop/logs"]

# Copy the bootstrap shell
ADD starthdp.sh /opt/hadoop/bin/
ADD stophdp.sh /opt/hadoop/bin/
ADD restarthdp.sh /opt/hadoop/bin/
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh && chmod +x /opt/hadoop/bin/starthdp.sh && chmod +x /opt/hadoop/bin/stophdp.sh && chmod +x /opt/hadoop/bin/restarthdp.sh
ENTRYPOINT ["/usr/bin/start.sh"] 




