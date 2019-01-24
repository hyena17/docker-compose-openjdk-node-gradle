FROM ubuntu:rolling AS BASE_IMAGE
RUN apt-get update && apt-get install -y wget build-essential apt-transport-https ca-certificates curl gnupg2 software-properties-common tar git openssl gzip unzip

## Helm Tiller
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash && \
    helm version --client && \
    tiller -version

## Kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl

## Docker
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-18.09.1.tgz > docker.tar.gz && tar xzvf docker.tar.gz -C /usr/local/bin/ --strip-components=1 && \
    rm docker.tar.gz && \
    docker -v

## Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose -v

# Kompose
RUN curl -L https://github.com/kubernetes/kompose/releases/download/v1.17.0/kompose-linux-amd64 -o /usr/local/bin/kompose && \
    chmod +x /usr/local/bin/kompose && \
    kompose -v

## Rancher Compose
RUN curl -L https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.xz | tar xJvf -  --strip-components=2 -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/rancher-compose && \
    rancher-compose --version

## Install Node
RUN curl -sL https://deb.nodesource.com/setup_10.x > install.sh && chmod +x install.sh && ./install.sh && \
    apt-get install -y nodejs

# TODO vielleicht wieder Phantomjs rein :(
# Neustes npm
RUN npm install -g npm@latest

FROM BASE_IMAGE
ARG GRADLE_VERSION=4.10.3
ARG JDK_VERSION=8
## Openjdk 
RUN apt install -y openjdk-${JDK_VERSION}-jdk-headless 
## Gradle
ENV GRADLE_HOME /opt/gradle
RUN wget --output-document=gradle.zip  https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle.zip && \
    rm gradle.zip && \
    mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" && \
    ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

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

