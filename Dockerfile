FROM ubuntu:rolling

RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates curl gnupg2 software-properties-common tar git openssl gzip unzip\
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

## Docker
ARG DOCKER=19.03.8
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER}.tgz > docker.tar.gz && tar xzvf docker.tar.gz -C /usr/local/bin/ --strip-components=1 && \
    rm docker.tar.gz && \
    docker -v

## Docker Compose
ARG DOCKER_COMPOSE=1.25.4
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose -v

## Node.js
ARG NODE=12.x
RUN curl -sL https://deb.nodesource.com/setup_${NODE} > install.sh && chmod +x install.sh && ./install.sh && \
    apt-get install -y nodejs\
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && rm install.sh

# npm
RUN npm install -g npm@latest

# Standard Encoding von ASCII auf UTF-8 stellen
ENV LANG C.UTF-8

## OpenJDK
ARG JDK_VERSION=8
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-${JDK_VERSION}-jdk \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

## Gradle
ARG GRADLE_VERSION=4.10.3
ENV GRADLE_HOME /opt/gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    --output-document=gradle.zip && \
    unzip gradle.zip && \
    rm gradle.zip && \
    mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" && \
    ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

## Maven
RUN apt-get install maven

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
