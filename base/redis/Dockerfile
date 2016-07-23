FROM localreg:5000/ubuntu-confd-monit-ssh-host:14.04
MAINTAINER "zhangjun <ibmzhangjun@icloud.com>"

RUN mkdir -p /data
ENV DEBIAN_FRONTEND noninteractive

#Upgrade ubuntu
RUN apt-get -q update && apt-get install -qy ca-certificates && apt-get clean

ENV REDIS_VERSION 3.2.1

COPY redis.tar /usr/src/
RUN buildDeps='gcc libc6-dev make' \
	&& set -x \
	&& apt-get install -y $buildDeps --no-install-recommends \
  && cd /usr/src/ && tar -xf redis.tar \
	&& rm redis.tar \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps

#Clean
RUN apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

#COPY redis.conf
COPY redis.conf /etc/

# Copy the bootstrap shell
COPY start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
RUN groupadd -r redis && useradd -r -g redis redis
RUN chown redis:redis /data
VOLUME /data
WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["/usr/bin/start.sh"] 