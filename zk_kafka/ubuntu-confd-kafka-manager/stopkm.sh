#!/usr/bin/env sh  
ps -ef|grep kafka-manager.kafka-manager |grep -v grep
if [ $? -ne 0 ]; then
echo "kafka-manager seems not running....."
else
echo "kafka-manager is running, stop it....."
killall java
if [ -f /opt/kafka-manager/RUNNING_PID ]; then
        rm /opt/kafka-manager/RUNNING_PID
fi
fi
