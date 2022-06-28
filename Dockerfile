FROM ubuntu:rolling

RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates curl gnupg2 software-properties-common tar git openssl gzip unzip\
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

## Python
RUN apt install python3

## Docker
ARG DOCKER=20.10.14
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER}.tgz > docker.tar.gz && tar xzvf docker.tar.gz -C /usr/local/bin/ --strip-components=1 && \
    rm docker.tar.gz && \
    docker -v

## Docker Compose
ARG DOCKER_COMPOSE=v2.6.1
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose -v

# Standard Encoding von ASCII auf UTF-8 stellen
ENV LANG C.UTF-8

## OpenJDK
ARG JDK_VERSION=11
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-${JDK_VERSION}-jdk \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

## Scala && SBT
# Install sbt
ARG SCALA_VERSION=2.13.8
ARG SBT_VERSION=1.6.2
RUN curl -fsL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar xfz - -C /usr/share && \
  chown -R root:root /usr/share/sbt && \
  chmod -R 755 /usr/share/sbt && \
  ln -s /usr/share/sbt/bin/sbt /usr/local/bin/sbt && \
  sbt --version

# Install Scala
RUN case $SCALA_VERSION in \
    "3"*) URL=https://github.com/lampepfl/dotty/releases/download/${SCALA_VERSION}/scala3-${SCALA_VERSION}.tar.gz SCALA_DIR=/usr/share/scala3-${SCALA_VERSION} ;; \
    *) URL=https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz SCALA_DIR=/usr/share/scala-${SCALA_VERSION} ;; \
  esac && \
  curl -fsL $URL | tar xfz - -C /usr/share && \
  mv $SCALA_DIR /usr/share/scala && \
  chown -R root:root /usr/share/scala && \
  chmod -R 755 /usr/share/scala && \
  ln -s /usr/share/scala/bin/* /usr/local/bin && \
  case ${SCALA_VERSION} in \
    "3"*) echo "@main def main = println(util.Properties.versionMsg)" > test.scala ;; \
    *) echo "println(util.Properties.versionMsg)" > test.scala ;; \
  esac && \
  scala -nocompdaemon test.scala && rm test.scala &&\\
  scala --version

## Maven
RUN wget --no-verbose -O /tmp/apache-maven-3.8.1.tar.gz http://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz

RUN tar xzf /tmp/apache-maven-3.8.1.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.8.1 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.8.1.tar.gz
ENV MAVEN_HOME /opt/maven

## emundo User
RUN addgroup --gid 1101 rancher && \
    # Für RancherOS brauchen wir diese Gruppe: http://rancher.com/docs/os/v1.1/en/system-services/custom-system-services/#creating-your-own-console
    addgroup --gid 999 aws && \
    # Für die AWS brauchen wir diese Gruppe
    useradd -ms /bin/bash emundo && \
    adduser emundo sudo && \
    # Das ist notwendig, damit das Image in RancherOS funktioniert
    usermod -aG 999 emundo && \
    # Das ist notwendig, damit das Image in RancherOS funktioniert
    usermod -aG 1101 emundo && \
    # Das ist notwendig, damit das Image lokal funktioniert
    usermod -aG root emundo

USER emundo
WORKDIR /home/emundo
