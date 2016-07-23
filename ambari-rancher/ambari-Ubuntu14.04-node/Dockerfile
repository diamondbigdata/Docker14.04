FROM diamondreg:5000/ubuntu-confd-monit-ssh-host:14.04
MAINTAINER Docker zhangjun <ibmzhangjun@icloud.com>

RUN mkdir -p /data
ENV DEBIAN_FRONTEND noninteractive

#Ambari ENV
ENV AMBARI_ROLE Node
ENV AMBARI_REPO Ambari/repo  
ENV AMBARI_SERVER Ambari/abserver
ENV AMBARI_NODE Ambari/abnode1

RUN rm /etc/apt/sources.list
ADD sources.list /etc/apt/
ADD ambari.list /etc/apt/sources.list.d
ADD HDP.list /etc/apt/sources.list.d
ADD HDP-UTILS.list /etc/apt/sources.list.d
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update && apt-get -qy upgrade && apt-get install -qy ntp
ADD ambariinst.tar /var/cache/apt/archives/
RUN apt-get install -qy mysql-connector-java ambari-agent && apt-get clean
#RUN /usr/sbin/update-rc.d -f ambari-agent remove

#Clean
RUN apt-get purge -y --auto-remove
RUN sudo rm -rf /var/lib/apt/lists/* 

# Copy the Site files up
# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/ 

# Copy the bootstrap shell 
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
ADD startrestthrift.sh /usr/bin/startrestthrift.sh
RUN chmod +x /usr/bin/startrestthrift.sh

EXPOSE 22

# Location to store data
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/start.sh"] 
