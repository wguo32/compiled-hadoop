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

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop-2.7.5
ENV ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10
ENV PATH=$PATH:/usr/local/hadoop-2.7.5/bin:/usr/local/hadoop-2.7.5/sbin 

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
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/start-zookeeper.sh ~/start-zookeeper.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/zoo.cfg /usr/local/zookeeper-3.4.10/conf/

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/start-zookeeper.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

