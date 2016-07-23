#!/usr/bin/env sh
ps -ef|grep kafka-manager.kafka-manager |grep -v grep
if [ $? -ne 0 ]; then
echo "kafka-manager seems not running, start it....."
nohup /opt/kafka-manager/bin/kafka-manager > /opt/kafka-manager/logs/km.log 2>&1 &
else
echo "kafka-manager is running, stop it....."
killall java
if [ -f /opt/kafka-manager/RUNNING_PID ]; then
        rm /opt/kafka-manager/RUNNING_PID
fi
echo "then start it....."
nohup /opt/kafka-manager/bin/kafka-manager > /opt/kafka-manager/logs/km.log 2>&1 &
fi                                      
