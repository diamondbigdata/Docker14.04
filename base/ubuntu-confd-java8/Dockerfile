FROM diamondreg:5000/ubuntu-confd-monit-ssh-host:14.04
MAINTAINER "zhangjun <ibmzhangjun@icloud.com>"

ADD jdk.tar /usr/lib/jvm
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/bin/java 3000
RUN update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/javac 3000


