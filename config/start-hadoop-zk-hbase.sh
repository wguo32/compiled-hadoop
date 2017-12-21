#!/bin/bash

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

$ZOOKEEPER_HOME/bin/zkServer.sh start

echo -e "\n"

$HBASE_HOME/bin/start-hbase.sh

echo -e "\n"
