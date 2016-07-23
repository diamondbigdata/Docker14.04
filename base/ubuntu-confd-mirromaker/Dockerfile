FROM localreg:5000/ubuntu-confd-monit-ssh-host:14.04
MAINTAINER "zhangjun <ibmzhangjun@icloud.com>"

RUN mkdir -p /data
ENV DEBIAN_FRONTEND noninteractive

#Upgrade ubuntu
RUN apt-get -q update && apt-get install -qy apt-mirror && apt-get clean

#Clean
RUN apt-get purge -y --auto-remove
RUN sudo rm -rf /var/lib/apt/lists/*

# Copy the bootstrap shell
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/start.sh"] 

