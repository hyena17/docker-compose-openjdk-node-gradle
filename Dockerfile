FROM openjdk:latest

RUN apt-get update

## Install Node
RUN curl -sL https://deb.nodesource.com/setup_8.x > install.sh && chmod +x install.sh && ./install.sh
RUN apt-get install -y nodejs

RUN apt-get install -y build-essential apt-transport-https ca-certificates curl gnupg2 software-properties-common tar

## Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

## Docker
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-17.09.0-ce.tgz > docker.tar.gz && tar xzvf docker.tar.gz -C /usr/local/bin/ --strip-components=1
RUN rm docker.tar.gz && docker -v

## Gradle
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.2.1
RUN wget --output-document=gradle.zip  https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle 
