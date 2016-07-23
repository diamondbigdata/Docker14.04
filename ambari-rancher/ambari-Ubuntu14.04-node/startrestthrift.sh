#!/bin/bash
/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift -p 9000 --infoport 9000
/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start rest -p 8090 --infoport 8090
