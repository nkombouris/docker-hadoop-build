# Create an image to build Hadoop nativelibs
#
# docker build -t sequenceiq/hadoop-nativelibs .

FROM tianon/centos:6.5
MAINTAINER SequenceIQ

USER root

# install dev tools
RUN yum install -y curl which tar sudo openssh-server openssh-clients rsync bunzip2; yum clean all

# install hadoop nativelins tools
RUN yum install -y gcc gcc-c++ autoconf automake libtool zlib-devel cmake; yum clean all

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# java
#RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
#RUN rpm -i jdk-7u51-linux-x64.rpm
#RUN rm jdk-7u51-linux-x64.rpm
#ENV JAVA_HOME /usr/java/default

RUN yum -y install java-1.8.0-openjdk-devel ; yum clean all
RUN cd /usr/lib/jvm ; dir
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk.x86_64
ENV PATH $PATH:$JAVA_HOME/bin


# devel tools
RUN yum groupinstall "Development Tools" -y; yum clean all
RUN yum install -y cmake zlib-devel openssl-devel; yum clean all

# maven
ENV M2_VER=3.5.0
RUN curl http://www.eu.apache.org/dist/maven/maven-3/${M2_VER}/binaries/apache-maven-${M2_VER}-bin.tar.gz|tar xz  -C /usr/share
ENV M2_HOME /usr/share/apache-maven-${M2_VER}
ENV PATH $PATH:$M2_HOME/bin

# hadoop
# RUN curl -s http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.0/hadoop-2.7.0-src.tar.gz | tar -xz -C /tmp/
ENV HADOOP_VER=hadoop-3.0.0-alpha4
RUN curl -s http://www.eu.apache.org/dist/hadoop/common/${HADOOP_VER}/${HADOOP_VER}-src.tar.gz | tar -xz -C /tmp/

# protoc -ohhh
#RUN curl https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2 | bunzip2|tar -x -C /tmp
RUN curl -LOk https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
RUN tar -xvf protobuf-2.5.0.tar.gz -C /tmp/ 
RUN cd /tmp/protobuf-2.5.0 && ./configure
RUN cd /tmp/protobuf-2.5.0 && make && make install
ENV LD_LIBRARY_PATH /usr/local/lib
ENV export LD_RUN_PATH /usr/local/lib

# build native libs
RUN cd /tmp/${HADOOP_VER}-src && mvn package -Pdist,native -DskipTests -Dtar

# tar to stdout
CMD tar -cv -C /tmp/${HADOOP_VER}-src/hadoop-dist/target/${HADOOP_VER}/lib/native/ .

# docker run --rm  sequenceiq/hadoop-nativelibs > x.tar
# get bintray helper
#RUN curl -Lo /tmp/bintray-functions j.mp/bintray-functions && . /tmp/bintray-functions
