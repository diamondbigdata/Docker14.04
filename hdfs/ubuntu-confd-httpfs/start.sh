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

#functions
set -e

function log {
    echo `date` $ME - $@
}

function checkrancher {
    log "checking rancher network..."
    a="1"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`"
        sleep 1
    done

    b="1"
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


#ENV
HDP_START_TIMEWAIT=${HDP_START_TIMEWAIT:-2}
CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-12-19"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
CONFD_ONETIME="/usr/bin/confd -onetime ${CONFD_PARAMS}"
CONFD_SCRIPT=${CONFD_SCRIPT:-"/tmp/confd-start.sh"}

#HDPRole: pnnode|snnode|jnode|zkfc|dnode|bash
HDPRole=${HDPRole:-"httpfs"}

HADOOP_PREFIX=${HADOOP_PREFIX:-"/opt/hadoop"}
HDPClusterName=${HDPClusterName:-"DiamondHDP"}
ZK_SERVICE=${ZK_SERVICE:-"HDP/zk"}
PNode_SERVICE=${PNode_SERVICE:-"HDP/pnode"}
SNode_SERVICE=${SNode_SERVICE:-"HDP/snode"}
JNode_SERVICE=${JNode_SERVICE:-"HDP/jnode"}
PNode_SERVICE_HostName=${PNode_SERVICE_HostName:-"PNameNode"}
SNode_SERVICE_HostName=${SNode_SERVICE_HostName:-"SNameNode"}
HADOOP_HDFS_NAMENODE=${HADOOP_HDFS_NAMENODE:-"/data/hdfs/namenode"}
HADOOP_HDFS_JOURNALNODE=${HADOOP_HDFS_JOURNALNODE:-"/data/hdfs/journal"}
HADOOP_HDFS_DATANODE=${HADOOP_HDFS_DATANODE:-"/data/hdfs/datanode"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS HDPRole HDPClusterName ZK_SERVICE PNode_SERVICE SNode_SERVICE JNode_SERVICE PNode_SERVICE_HostName SNode_SERVICE_HostName HADOOP_HDFS_NAMENODE HADOOP_HDFS_JOURNALNODE HADOOP_HDFS_DATANODE
checkrancher

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"

    # Create confd start script
    echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
    echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /opt/hadoop/logs/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
    echo "rc=\$?" >> ${CONFD_SCRIPT}
    echo "echo \$rc" >> ${CONFD_SCRIPT}
    chmod 755 ${CONFD_SCRIPT}

    log "[ Refreshing broker configuration every ${CONFD_INTERVAL} seconds... ]"
else
    #Execute confd in onepass. Removing confd monit script
    log "[ Static broker configuration... ]"
    rmconfd
fi

# Run confd to get first configuration
log "[ Getting hadoop configuration... ]"
${CONFD_ONETIME}
sleep $HDP_START_TIMEWAIT
${CONFD_ONETIME}
sleep $HDP_START_TIMEWAIT
${CONFD_ONETIME}
sleep $HDP_START_TIMEWAIT
/opt/hadoop/bin/starthttpfs.sh

# Run monit
log "[ Starting monit... ]"
/usr/bin/monit -I 
