FROM diamondreg:5000/ubuntu-confd-java8:14.04

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

WORKDIR /root
ADD sources.list /etc/apt/

COPY google-chrome-stable_current_amd64.deb /home/google-chrome-stable_current_amd64.deb
COPY ideaIC-2016.2.tar.gz /home/ideaIC-2016.2.tar.gz
COPY scala-intellij-bin-2016.2.1.zip /home/scala-intellij-bin-2016.2.1.zip
RUN apt-get update \
    && apt-get install -qy supervisor \
        pwgen sudo vim-tiny x11vnc x11vnc-data \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox \
        fonts-wqy-microhei \
        nginx \
	ssh \
        python-pip python-dev build-essential python-setuptools \
        mesa-utils libgl1-mesa-dri \
        gconf-service libnspr4 libnss3 fonts-liberation \
        libappindicator1 libcurl3 fonts-wqy-microhei
RUN dpkg -i /home/google-chrome-stable_current_amd64.deb \
    && apt-get install -f \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD web /web/
RUN pip install -r /web/requirements.txt

ADD noVNC /noVNC/
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD start.sh /usr/bin/
RUN chmod 755 /usr/bin/start.sh
ADD supervisord.conf /etc/supervisor/conf.d/
ADD doro-lxde-wallpapers /usr/share/doro-lxde-wallpapers/

EXPOSE 6080
WORKDIR /root
ENTRYPOINT ["/usr/bin/start.sh"]
