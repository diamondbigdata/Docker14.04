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

#start ntp
ps -ef|grep ntpd |grep -v grep
if [ $? -ne 0 ]; then
echo "ntpd seems not running, start it....."
/usr/sbin/ntpd -p /var/run/ntpd.pid -g -u 103:106
else
echo "ntpd is running....."
fi

#functions
#set -e

function checkport {
    netstat -an | grep 8080
    while [ $? -ne 0 ]
    do
        echo "Ambari server not start ... wait for 2s and check..."
        sleep 2
        netstat -an | grep 8080 
    done 
    echo "Ambari server started, pls access the web ui via port 8080 or loadblancer !"
}

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
AMBARI_REPO=${AMBARI_REPO:-"Ambari/repo"}
AMBARI_SERVER=${AMBARI_SERVER:-"Ambari/abserver"}
AMBARI_NODE=${AMBARI_NODE:-"Ambari/abnode1"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS AMBARI_REPO AMBARI_SERVER AMBARI_NODE

checkrancher

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"

    # Create confd start script
    echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
    echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /tmp/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
    echo "rc=\$?" >> ${CONFD_SCRIPT}
    echo "echo \$rc" >> ${CONFD_SCRIPT}
    chmod 755 ${CONFD_SCRIPT}

    log "[ Refreshing hosts every ${CONFD_INTERVAL} seconds... ]"
else
    #Execute confd in onepass. Removing confd monit script
    log "[ Static hosts configuration... ]"
    rmconfd
fi

# Run confd to get first appli configuration
log "[ Getting hosts configuration... ]"
${CONFD_ONETIME}
sleep 1
${CONFD_ONETIME}
sleep 1
${CONFD_ONETIME}
sleep 1
if [[ ! -a /etc/ambari-server/conf/password.dat ]]; then
	echo "Ambari Server Setup ..."
	/usr/sbin/ambari-server setup -s
	sleep 5
fi
nohup /usr/sbin/ambari-server start > /tmp/ambari-server-start.log 2>&1 &
sleep 5

#check port 8080
netstat -an | grep 8080
    while [ $? -ne 0 ]
    do
        echo "Ambari server not start ... wait for 2s and check again..."
        sleep 2
        netstat -an | grep 8080
    done
    echo "Ambari server started, pls access the web ui via port 8080 or loadblancer !"

sleep 1
#Run monit
log "[ Starting monit... ]"
/usr/bin/monit -I
