FROM ubuntu:16.04

MAINTAINER wguo32

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget
#install zookeeper
RUN wget http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz && \
	tar -xzf zookeeper-3.4.10.tar.gz && \
	mv zookeeper-3.4.10 /usr/local/zookeeper-3.4.10 && \
	rm zookeeper-3.4.10.tar.gz

# install hadoop 2.7.5
RUN wget -O hadoop-2.7.5.tar.gz https://master.dl.sourceforge.net/project/dockered-hadoop/2.7.5/hadoop-2.7.5.tar.gz  && \
    tar -xzf hadoop-2.7.5.tar.gz && \
    mv hadoop-2.7.5 /usr/local/hadoop-2.7.5 && \
    rm hadoop-2.7.5.tar.gz
#install hbase    
RUN wget http://www.gtlib.gatech.edu/pub/apache/hbase/1.2.6/hbase-1.2.6-bin.tar.gz && \
    tar -xzf hbase-1.2.6-bin.tar.gz && \
    mv hbase-1.2.6 /usr/local/hbase-1.2.6 && \
    rm hbase-1.2.6-bin.tar.gz


# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop-2.7.5
ENV ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10
ENV HBASE_HOME=/usr/local/hbase-1.2.6
ENV PATH=$PATH:HADOOP_HOME/bin:HADOOP_HOME/sbin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf/ && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/ && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/ && \
    mv /tmp/regionservers $HBASE_HOME/conf/ && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/stop-hadoop.sh ~/stop-hadoop.sh && \
    mv /tmp/start-zookeeper.sh ~/start-zookeeper.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/start-hadoop-zk-hbase.sh ~/start-hadoop-zk-hbase.sh && \
    mv /tmp/stop-hadoop-zk-hbase.sh ~/stop-hadoop-zk-hbase.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/start-zookeeper.sh && \
    chmod +x ~/start-hadoop-zk-hbase.sh && \
    chmod +x ~/stop-hadoop-zk-hbase.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

