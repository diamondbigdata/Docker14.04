#!/bin/bash
HDPRole=${HDPRole:-"dnode"}
HADOOP_PREFIX=${HADOOP_PREFIX:-"/opt/hadoop"}
HADOOP_HDFS_NAMENODE=${HADOOP_HDFS_NAMENODE:-"/data/hdfs/namenode"}

# Read the HDPRole env, and based upon one of the five: format or bootstrap or start the particular service
# NN and ZKFC stick together
case $HDPRole in
  pnnode)
    /usr/bin/killall java
    ;;
  snnode)
    /usr/bin/killall java
    ;;
  zkfc)
    /usr/bin/killall java
    ;;
  jnode)
    /usr/bin/killall java
    ;;
  dnode)
    /usr/bin/killall java
    ;;
  bash)
    /bin/bash
    ;;
  *)
    echo $"Usage: {pnnode|snnode|jnode|zkfc|dnode|bash}"
    eval $*
esac
