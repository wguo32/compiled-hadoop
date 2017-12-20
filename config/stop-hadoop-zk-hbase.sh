#!/bin/bash

echo -e "\n"

$HBASE/bin/stop-hbase.sh

echo -e "\n"

$ZOOKEEPER_HOME/bin/zkServer.sh stop

echo -e "\n"

$HADOOP_HOME/sbin/stop-all.sh

echo -e "\n"
