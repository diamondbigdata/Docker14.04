FROM diamondreg:5000/hue-base:3.10
MAINTAINER "ZhangJun <ibmzhangjun@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# Add start script
RUN rm /usr/bin/start.sh
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh
EXPOSE 8000
ENTRYPOINT ["/usr/bin/start.sh"]
