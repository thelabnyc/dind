ARG UBUNTU_VERSION=16.04
FROM ubuntu:${UBUNTU_VERSION}

# Install Python and misc utils
RUN apt-get update && \
    apt-get install -y git wget unzip jq python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --upgrade pip ipython pytz flake8

# Install Docker client
 RUN apt-get update && \
     apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
     apt-key fingerprint 0EBFCD88 && \
     add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
     apt-get update && \
     apt-get install -y docker-ce && \
     pip3 install docker-py

# Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
