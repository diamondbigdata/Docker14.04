FROM diamondreg:5000/ubuntu-confd-java8:14.04
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# Set environment
ENV HUE_VERSION=release-3.10.0 \
    HUE_HOME=/opt/hue 

ADD hue.tar /opt

#Install dependence
RUN apt-get -q update && apt-get -qy upgrade && \
    apt-get install -qy build-essential maven libkrb5-dev \
    libldap2-dev libmysqlclient-dev libsasl2-dev libsasl2-modules-gssapi-mit \
    libsqlite3-dev libssl-dev libtidy-0.99-0 libxml2-dev libxslt-dev \
    mysql-server python-dev python-setuptools python-simplejson ant gcc g++ \
    libffi-dev libkrb5-dev libmysqlclient-dev libsasl2-dev libsasl2-modules-gssapi-mit \
    libsqlite3-dev libssl-dev libxml2-dev libxslt-dev make maven libldap2-dev python-dev python-setuptools libgmp3-dev libz-dev && apt-get clean

WORKDIR /opt/hue
RUN make apps

#Clean
RUN apt-get purge -y --auto-remove
RUN sudo rm -rf /var/lib/apt/lists/*

# Add confd tmpl and toml
#ADD confd/*.toml /etc/confd/conf.d/
#ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
RUN mkdir -p /opt/zk/logs
WORKDIR $HUE_HOME
EXPOSE 8000
#ENTRYPOINT ["/usr/bin/start.sh"]
