ARG BASE_IMAGE=ubuntu
ARG UBUNTU_VERSION
FROM ${BASE_IMAGE}:${UBUNTU_VERSION}

# Install Python and misc utils
RUN apt-get update && \
    apt-get install -y git wget unzip jq python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --upgrade pip ipython pytz flake8

# Configure Timezone
ARG TIMEZONE="America/New_York"
RUN echo "${TIMEZONE}" > /etc/timezone && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq tzdata

# Install Docker client
ARG DOCKER_VERSION
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    mkdir -p /etc/apt/keyrings  && \
    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | gpg --dearmor -o "/etc/apt/keyrings/docker.gpg" && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y \
        docker-ce=${DOCKER_VERSION} \
        docker-ce-cli=${DOCKER_VERSION} \
        containerd.io \
        docker-compose-plugin

# Install docker-compose
ARG COMPOSE_VERSION
RUN curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
