#!/bin/bash

# the default node number is 3
N=${1:-3}


# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 8020:8020 \
                -p 2888:2888 \
                -p 3888:3888 \
                -p 2181:2181 \
                -p 16000:16000 \
                -p 16010:16010 \
                -p 16020:16020 \
                -p 16030:16030 \
                -p 8080:8080 \
                -p 8085:8085 \
                -p 9090:9090 \
                -p 9095:9095 \
                --name hadoop-master \
                --hostname hadoop-master \
                wguo32/compiled-hadoop:latest &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                wguo32/compiled-hadoop:latest &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
sudo docker exec -it hadoop-master bash
