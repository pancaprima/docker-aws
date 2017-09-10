FROM amazon/aws-eb-python:3.4.2-onbuild-3.5.1

#USER root
RUN apt-get update
RUN apt-get install -y wget

############
# Oracle JDK
############

# Preparation

ARG JAVA_VERSION=8
ARG JAVA_RELEASE=JDK

ENV JAVA_HOME=/usr

RUN echo "deb http://ftp.ru.debian.org/debian/ jessie-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list && \
    echo "deb http://ftp.ru.debian.org/debian/ jessie main contrib non-free"           > /etc/apt/sources.list && \
    echo "deb http://ftp.ru.debian.org/debian/ jessie-updates main contrib non-free"   >> /etc/apt/sources.list &&\
    echo "deb http://security.debian.org jessie/updates main contrib non-free"         >> /etc/apt/sources.list  

# locales
RUN apt-get update && apt-get install  locales-all  -y \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    pkg="openjdk-$JAVA_VERSION"; \
    if [ "$JAVA_RELEASE" = "JDK" ]; then \
        pkg="$pkg-jdk-headless"; \
    else \
        pkg="$pkg-jre-headless"; \
    fi; \
    apt-get install -t jessie-backports -y --no-install-recommends "$pkg" && \
    apt-get clean

CMD /bin/bash

#######
# Maven
#######

# Preparation

ENV MAVEN_VERSION 3.3.3
ENV MAVEN_HOME /etc/maven-${MAVEN_VERSION}

# Installation

RUN cd /tmp
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN mkdir maven-${MAVEN_VERSION}
RUN tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz --directory maven-${MAVEN_VERSION} --strip-components=1
RUN mv maven-${MAVEN_VERSION} ${MAVEN_HOME}
ENV PATH ${PATH}:${MAVEN_HOME}/bin

# Cleanup

RUN rm apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN unset MAVEN_VERSION

#####
# Ant
#####

# Preparation

ENV ANT_VERSION 1.9.9
ENV ANT_HOME /etc/ant-${ANT_VERSION}

# Installation

RUN cd /tmp
RUN wget http://www.us.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz
RUN mkdir ant-${ANT_VERSION}
RUN tar -zxvf apache-ant-${ANT_VERSION}-bin.tar.gz --directory ant-${ANT_VERSION} --strip-components=1
RUN mv ant-${ANT_VERSION} ${ANT_HOME}
ENV PATH ${PATH}:${ANT_HOME}/bin

# Cleanup

RUN rm apache-ant-${ANT_VERSION}-bin.tar.gz
RUN unset ANT_VERSION

#########
# Testing
#########

RUN env
RUN java -version
RUN javac -version
RUN mvn -version
RUN ant -version
