#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [ $# = 0 ]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# change slaves file
i=1
rm config/slaves
while [ $i -lt $N ]
do
	echo "hadoop-slave$i" >> config/slaves
	((i++))
done 

echo ""

# change zookeeper file
i=1
rm config/zoo.cfg
echo -e "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/tmp/zookeeper\nclientPort=2181\nserver.1=hadoop.master:2888:3888" >> config/zoo.cfg
while [ $i -lt $N ]
do
	j=$((i+1))
	echo "server.$j=hadoop.slave$i:2888:3888" >> config/zoo.cfg
	((i++))
done 

echo ""

echo -e "\nbuild docker hadoop image\n"

# rebuild wguo/hadoop image
sudo docker build -t wguo32/hadoop:1.0 .

echo ""
