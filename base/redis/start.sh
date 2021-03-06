#!/usr/bin/env bash

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

#function
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

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-12-19"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
CONFD_ONETIME="/usr/bin/confd -onetime ${CONFD_PARAMS}"
CONFD_SCRIPT=${CONFD_SCRIPT:-"/tmp/confd-start.sh"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS
   
checkrancher

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"

    # Create confd start script
    echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
    echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /tmp/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
    echo "rc=\$?" >> ${CONFD_SCRIPT}
    echo "echo \$rc" >> ${CONFD_SCRIPT}
    chmod 755 ${CONFD_SCRIPT}

    log "[ Refreshing broker configuration every ${CONFD_INTERVAL} seconds... ]"
else
    #Execute confd in onepass. Removing confd monit script
    log "[ Static broker configuration... ]"
    rmconfd
fi

# Run confd to get first appli configuration
log "[ Getting broker configuration... ]"
${CONFD_ONETIME}

# RUN redis
echo "Please run the docker in privileged mode to ensure redis can change linux kernel parameters ..."

echo 511 > /proc/sys/net/core/somaxconn && sysctl vm.overcommit_memory=1 && echo never > /sys/kernel/mm/transparent_hugepage/enabled

/usr/bin/nohup /usr/local/bin/redis-server /etc/redis.conf  > /var/log/redis.log 2>&1 &

# Run monit
log "[ Starting monit... ]"
/usr/bin/monit -I
