#####################################
# Altibase docker file
#
# 07/20/2018
# swhors@coupang.com
#
# 2020-09-29
# teslamint@gmail.com
#
#####################################
# os image
FROM ubuntu:16.04 as builder

#####################################
# build environment
ARG ALTIBASE_VERSION=7.1.0.2.4
ARG RE2C_VERSION=0.13.5
ARG BISON_VERSION=2.7
ARG FLEX_VERSION=2.5.39

#####################################
# install basic development tools
# RUN sed -ie 's/archive.ubuntu/mirror.kakao/g' /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -qq -y autoconf autopoint help2man texinfo g++ gawk flex \
    libncurses5-dev binutils-dev ddd tkdiff manpages-dev libldap2-dev \
    cmake curl texlive libssl-dev libtool gettext build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#####################################
# patch sysctl
WORKDIR /opt

ADD sysctl_patch.sh ./
RUN bash sysctl_patch.sh && \
    rm sysctl_patch.sh

#####################################
# patch sys/select
ADD select.patch ./
RUN cd /usr/include/$(uname -m)-linux-gnu/sys && \
    patch -p1 < /opt/select.patch && \
    rm /opt/select.patch && \
    cd /opt

#####################################
# install re2c
RUN curl http://archive.ubuntu.com/ubuntu/pool/main/r/re2c/re2c_${RE2C_VERSION}.orig.tar.gz | tar xzf - && \
    cd re2c-${RE2C_VERSION} && \
    ./configure --prefix=/usr/local/ && make && make install && \
    cd .. && rm -fR re2c*
ENV PATH /usr/local/bin:$PATH

#####################################
# install bison
RUN curl https://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz | tar xzf - && \
    cd bison-${BISON_VERSION} && \
    ./configure --prefix=/usr/local/ && make && make install && \
    cd .. && rm -fR bison*
ENV PATH /usr/local/share/bison-${BISON_VERSION}/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/share/bison-${BISON_VERSION}/lib:$LD_LIBRARY_PATH

#####################################
# install flex
RUN curl -L https://github.com/westes/flex/releases/download/flex-${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz | tar xzf - && \
    cd flex-${FLEX_VERSION} && ./autogen.sh && ./configure --prefix=/usr/local/ && \
    make && make install && \
    cd .. && rm -fR flex*
ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH

#####################################
# install java 1.5 environment tools
ADD jdk-1_5_0_22-linux-amd64.bin ./
RUN chmod +x jdk-1_5_0_22-linux-amd64.bin && \
    (echo yes) | sh jdk-1_5_0_22-linux-amd64.bin && \
    mv jdk1.5.0_22 /usr/share/java && \
    rm -fR jdk*

ENV JAVA_HOME /usr/share/java/jdk1.5.0_22

#####################################
# install java 1.7
RUN curl -L https://github.com/frekele/oracle-java/releases/download/7u80-b15/jdk-7u80-linux-x64.tar.gz | tar xzf - -C /usr/share/java
ENV ADAPTER_JAVA_HOME /usr/share/java/jdk1.7.0_80

#####################################
# set go environments
ENV ALTIDEV_HOME	/opt/altibase
ENV ALTIBASE_DEV	/opt/altibase
ENV ALTIBASE_HOME	/opt/altibase/altibase_home
ENV ALTIBASE_NLS_USE	UTF8
ENV ALTIBASE_PORT_NO	20300
ENV CLASSPATH		.:${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib:${ALTIBASE_HOME}/lib/Altibase.jar:$CLASSPATH
ENV LD_LIBRARY_PATH	$ALTIBASE_HOME/lib:$LD_LIBRARY_PATH

RUN echo "alias godev='cd $ALTIBASE_DEV'" >> /root/.bashrc
ENV PATH $ALTIBASE_HOME/bin:$JAVA_HOME/bin:$PATH
ENV LANG en_US.UTF-8

#####################################
# get & build source code
RUN curl -L https://github.com/ALTIBASE/altibase/archive/${ALTIBASE_VERSION}.tar.gz | tar xzf - && \
    mv altibase-${ALTIBASE_VERSION} altibase && \
    cd altibase && \
    ./configure --with-build_mode=release && \
    make build -j$(nproc)

#####################################
# final image
FROM ubuntu:20.04 as final

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -qq -y openjdk-8-jre-headless && \
    apt-get autoremove -qq -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

#####################################
# patch sysctl
WORKDIR /opt
ADD sysctl_patch.sh ./
RUN bash sysctl_patch.sh && \
    rm sysctl_patch.sh

#####################################
# copy altibase file from builder image
RUN mkdir -p /opt/altibase

WORKDIR /opt/altibase
COPY --from=builder /opt/altibase/altibase_home /opt/altibase/altibase_home/

#####################################
# create altibase.properties
VOLUME ["/opt/altibase/data"]

ENV ALTIBASE_HOME	/opt/altibase/altibase_home
ENV ALTIBASE_NLS_USE	UTF8
ENV ALTIBASE_PORT_NO	20300
ENV CLASSPATH		.:${JAVA_HOME}/jre/lib:${ALTIBASE_HOME}/lib/Altibase.jar:$CLASSPATH
ENV LD_LIBRARY_PATH	$ALTIBASE_HOME/lib:$LD_LIBRARY_PATH
ENV PATH $ALTIBASE_HOME/bin:$JAVA_HOME/bin:$PATH
ENV LANG en_US.UTF-8

ENV ALTIDATAHOME /opt/altibase/data
ENV TRCHOME      $ALTIDATAHOME/trc
ENV DISKDBHOME   $ALTIDATAHOME/dbs
ENV MEMDBHOME    $ALTIDATAHOME/dbs
ENV LOGSHOME     $ALTIDATAHOME/logs
ENV ARCHIVE_DIR  $ALTIDATAHOME/arch_logs

ADD patch_property.sh /opt/altibase/altibase_home/conf/
RUN cd $ALTIBASE_HOME/conf && \
    bash patch_property.sh && \
    rm -f patch_property.sh

#####################################
# create entrypoint
COPY entrypoint.sh /entrypoint.sh

EXPOSE     20300

ENTRYPOINT ["sh", "/entrypoint.sh"]
