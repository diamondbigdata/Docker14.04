#!/bin/bash
HDPRole=${HDPRole:-"dnode"}
HADOOP_PREFIX=${HADOOP_PREFIX:-"/opt/hadoop"}
HADOOP_HDFS_NAMENODE=${HADOOP_HDFS_NAMENODE:-"/data/hdfs/namenode"}

# Read the HDPRole env, and based upon one of the five: format or bootstrap or start the particular service
# NN and ZKFC stick together
case $HDPRole in
  pnnode)
    if [[ ! -a $HADOOP_HDFS_NAMENODE/current/VERSION ]]; then
      echo "Format Namenode.."
      nohup $HADOOP_PREFIX/bin/hdfs namenode -format -force > /opt/hadoop/logs/namenode-format-`date +%Y-%m-%d`.out 2>&1 &

      echo "Format Zookeeper for Fast failover.."
      nohup $HADOOP_PREFIX/bin/hdfs zkfc -formatZK -force > /opt/hadoop/logs/zkfc-format-`date +%Y-%m-%d`.out 2>&1 &
    fi
    nohup $HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc > /opt/hadoop/logs/zkfc-`date +%Y-%m-%d`.out 2>&1 &
    nohup $HADOOP_PREFIX/bin/hdfs namenode > /opt/hadoop/logs/namenode-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  snnode)
    if [[ ! -a $HADOOP_HDFS_NAMENODE/current/VERSION ]]; then
      echo "Bootstrap Standby Namenode.."
      nohup $HADOOP_PREFIX/bin/hdfs namenode -bootstrapStandby > /opt/hadoop/logs/namenode-bootstrapStandby-`date +%Y-%m-%d`.out 2>&1 &
    fi
    nohup $HADOOP_PREFIX/sbin/hadoop-daemon.sh start zkfc  > /opt/hadoop/logs/zkfc-`date +%Y-%m-%d`.out 2>&1 &
    nohup $HADOOP_PREFIX/bin/hdfs namenode > /opt/hadoop/logs/namenode-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  zkfc)
    nohup $HADOOP_PREFIX/bin/hdfs zkfc > /opt/hadoop/logs/zkfc-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  jnode)
    nohup $HADOOP_PREFIX/bin/hdfs journalnode > /opt/hadoop/logs/journalnode-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  dnode)
    nohup $HADOOP_PREFIX/bin/hdfs datanode > /opt/hadoop/logs/datanode-`date +%Y-%m-%d`.out 2>&1 &
    ;;
  bash)
    /bin/bash
    ;;
  *)
    echo $"Usage: {pnnode|snnode|jnode|zkfc|dnode|bash}"
    eval $*
esac 
