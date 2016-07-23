#!/bin/bash

#start ssh first
if [[ ! -a /var/run/sshd ]]; then
        mkdir /var/run/sshd
fi
ps -ef|grep sshd |grep -v grep
if [ $? -ne 0 ]; then
echo "sshd seems not running, start it....."
nohup /usr/sbin/sshd > /tmp/sshd.log 2>&1 &
else
echo "sshd is running....."
fi

set -e

function log {
        echo `date` $ME - $@
}

function checkrancher {
    log "checking rancher network..."
    a="`ip a s dev eth0 &> /dev/null; echo $?`"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

   b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
    while [ $b -eq 1 ]; 
    do
        b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
        sleep 1 
    done
}


function rmconfd {
    if [ -f /etc/monit/conf.d/confd.conf ]; then
        rm /etc/monit/conf.d/confd.conf
    fi
}

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-12-19"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
CONFD_ONETIME="/usr/bin/confd -onetime ${CONFD_PARAMS}"
CONFD_SCRIPT=${CONFD_SCRIPT:-"/tmp/confd-start.sh"}
JVMFLAGS=${JVMFLAGS:-"-Xms512m -Xmx512m"}

#Spart ENV
SPARK_ROLE=${SPARK_ROLE:-"master"} 
SPARK_IP=${SPARK_IP:-"sparkmaster"}
SPARK_WORKER_HOSTNAME=${SPARK_WORKER_HOSTNAME:-"sparkworker"}
SPARK_MASTER_IP=${SPARK_MASTER_IP:-"sparkmaster"} 
SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-"7077"} 
SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-"8080"} 
SPARK_MASTER_OPTS=${SPARK_MASTER_OPTS:-""} 
SPARK_WORKER_CORES=${SPARK_WORKER_CORES:-"4"} 
SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-"1g"}
SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-"8081"} 
SPARK_EXECUTOR_INSTANCES=${SPARK_EXECUTOR_INSTANCES:-"1"} 
SPARK_WORKER_DIR=${SPARK_WORKER_DIR:-"/opt/spark/work"} 
SPARK_WORKER_OPTS=${SPARK_WORKER_OPTS:-""} 
SPARK_DAEMON_MEMORY=${SPARK_DAEMON_MEMORY:-"1g"} 
SPARK_HISTORY_OPTS=${SPARK_HISTORY_OPTS:-""} 
SPARK_SHUFFLE_OPTS=${SPARK_SHUFFLE_OPTS:-""} 
SPARK_DAEMON_JAVA_OPTS=${SPARK_DAEMON_JAVA_OPTS:-""} 
SPARK_EVENTlOG_ENABLED=${SPARK_EVENTlOG_ENABLED:-"false"} 
SPARK_EVENTlOG_DIR=${SPARK_EVENTlOG_DIR:-"/tmp/sparkeventlog"} 
SPARK_SERIALIZER=${SPARK_SERIALIZER:-"org.apache.spark.serializer.KryoSerializer"} 
SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY:-"1g"} 
SPARK_EXECUTOR_EXTRAJAVAOPTIONS=${SPARK_EXECUTOR_EXTRAJAVAOPTIONS:-""} 

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS JVMFLAGS

export SPARK_ROLE SPARK_IP SPARK_WORKER_HOSTNAME SPARK_MASTER_IP SPARK_MASTER_PORT SPARK_MASTER_WEBUI_PORT SPARK_MASTER_OPTS
export SPARK_WORKER_CORES SPARK_WORKER_MEMORY SPARK_WORKER_WEBUI_PORT SPARK_EXECUTOR_INSTANCES SPARK_WORKER_DIR SPARK_WORKER_OPTS
export SPARK_DAEMON_MEMORY SPARK_HISTORY_OPTS SPARK_SHUFFLE_OPTS SPARK_DAEMON_JAVA_OPTS SPARK_EVENTlOG_ENABLED SPARK_EVENTlOG_DIR SPARK_SERIALIZER SPARK_DRIVER_MEMORY SPARK_EXECUTOR_EXTRAJAVAOPTIONS

checkrancher

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"

    # Create confd start script
    echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
    echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /tmp/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
    echo "rc=\$?" >> ${CONFD_SCRIPT}
    echo "echo \$rc" >> ${CONFD_SCRIPT}
    chmod 755 ${CONFD_SCRIPT}

    log "[ Refreshing configuration every ${CONFD_INTERVAL} seconds... ]"
else
    #Execute confd in onepass. Removing confd monit script
    log "[ Static configuration... ]"
    rmconfd
fi

# Run confd to get first appli configuration
log "[ Getting configuration... ]"
${CONFD_ONETIME}
sleep 3

#Init slaves
SLAVES_FILE=/opt/spark/conf/slaves
echo "" > $SLAVES_FILE
echo "# A Spark Worker will be started on each of the machines listed below." >> $SLAVES_FILE
for i in `echo "$SPARK_WORKER_HOSTNAME" | sed 's/,/\n/g'`
do  
    echo $i >> $SLAVES_FILE
done
cat $SLAVES_FILE

#Init spark-env.sh
ENV_FILE=/opt/spark/conf/spark-env.sh
echo "" > $ENV_FILE
echo "#!/usr/bin/env bash" >> $ENV_FILE
echo "# Options for the daemons used in the standalone deploy mode" >> $ENV_FILE
echo "export SPARK_MASTER_IP=$SPARK_MASTER_IP" >> $ENV_FILE
echo "export SPARK_MASTER_PORT=$SPARK_MASTER_PORT" >> $ENV_FILE
echo "export SPARK_MASTER_WEBUI_PORT=$SPARK_MASTER_WEBUI_PORT" >> $ENV_FILE
echo "export SPARK_MASTER_OPTS=$SPARK_MASTER_OPTS" >> $ENV_FILE
echo "export SPARK_WORKER_CORES=$SPARK_WORKER_CORES" >> $ENV_FILE
echo "export SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY" >> $ENV_FILE
echo "export SPARK_WORKER_WEBUI_PORT=$SPARK_WORKER_WEBUI_PORT" >> $ENV_FILE
echo "export SPARK_EXECUTOR_INSTANCES=$SPARK_EXECUTOR_INSTANCES" >> $ENV_FILE
echo "export SPARK_WORKER_DIR=$SPARK_WORKER_DIR" >> $ENV_FILE
echo "export SPARK_WORKER_OPTS=$SPARK_WORKER_OPTS" >> $ENV_FILE
echo "export SPARK_DAEMON_MEMORY=$SPARK_DAEMON_MEMORY" >> $ENV_FILE
echo "export SPARK_HISTORY_OPTS=$SPARK_HISTORY_OPTS" >> $ENV_FILE
echo "export SPARK_SHUFFLE_OPTS=$SPARK_SHUFFLE_OPTS" >> $ENV_FILE
echo "export SPARK_DAEMON_JAVA_OPTS=$SPARK_DAEMON_JAVA_OPTS" >> $ENV_FILE
cat $ENV_FILE
chmod 755 $ENV_FILE

#Init spark-defaults.conf
DEFAULT_FILE=/opt/spark/conf/spark-defaults.conf
echo "" > $DEFAULT_FILE
echo "# Default system properties included when running spark-submit." >> $DEFAULT_FILE
echo "# This is useful for setting default environmental settings." >> $DEFAULT_FILE
echo "spark.master                     spark://$SPARK_MASTER_IP:$SPARK_MASTER_PORT" >> $DEFAULT_FILE
echo "spark.eventLog.enabled           $SPARK_EVENTlOG_ENABLED" >> $DEFAULT_FILE
echo "spark.eventLog.dir               $SPARK_EVENTlOG_DIR" >> $DEFAULT_FILE
echo "spark.serializer                 $SPARK_SERIALIZER" >> $DEFAULT_FILE
echo "spark.driver.memory              $SPARK_DRIVER_MEMORY" >> $DEFAULT_FILE
echo "spark.executor.extraJavaOptions  $SPARK_EXECUTOR_EXTRAJAVAOPTIONS" >> $DEFAULT_FILE
cat $DEFAULT_FILE

#JAVA_ENV
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export JRE_HOME=${JAVA_HOME}/jre
export CLASS_PATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export SCALA_HOME=/usr/lib/scala/scala-2.10.6
export PATH=${JAVA_HOME}/bin:/usr/lib/scala/scala-2.10.6/bin:/opt/spark/bin:$PATH
ulimit -SHn 65535



#Start Spark
if [ $SPARK_ROLE == "master" ]; then
echo "start spark master ....."
/opt/spark/sbin/start-master.sh --ip $SPARK_IP
else
echo "start spark worker ....."
/opt/spark/sbin/start-slave.sh --ip $SPARK_IP spark://$SPARK_MASTER_IP:$SPARK_MASTER_PORT
fi

# Run monit
log "[ Starting monit... ]"
/usr/bin/monit -I
