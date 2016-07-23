FROM  diamondreg:5000/ubuntu-confd-monit-ssh-host:14.04
MAINTAINER "zhangjun <ibmzhangjun@icloud.com>"

RUN mkdir -p /data
ENV DEBIAN_FRONTEND noninteractive

#Upgrade ubuntu
RUN rm /etc/apt/sources.list
ADD sources.list /etc/apt/
RUN apt-get -q update && apt-get install -qy apache2 && apt-get clean

#Clean
RUN apt-get purge -y --auto-remove
RUN sudo rm -rf /var/lib/apt/lists/*

#make sys dir
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates
RUN rm -rf /var/lib/apt/lists/*
EXPOSE 80 443
VOLUME ["/data", "/var/www/html", "/var/log/apache2", "/etc/apache2"]
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
