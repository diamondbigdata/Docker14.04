#!/bin/bash
HDPRole=${HDPRole:-"httpfs"}
HADOOP_PREFIX=${HADOOP_PREFIX:-"/opt/hadoop"}
HADOOP_HDFS_NAMENODE=${HADOOP_HDFS_NAMENODE:-"/data/hdfs/namenode"}

# Read the HDPRole env, and based upon one of the five: format or bootstrap or start the particular service
# NN and ZKFC stick together
case $HDPRole in
  httpfs)
    nohup $HADOOP_PREFIX/sbin/httpfs.sh run > /opt/hadoop/logs/httpfs-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  bash)
    /bin/bash
    ;;
  *)
    echo $"Usage: {httpfs|bash}"
    eval $*
esac 
