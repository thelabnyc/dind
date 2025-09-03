ARG BASE_IMAGE=ubuntu
ARG UBUNTU_VERSION=24.04@sha256:9cbed754112939e914291337b5e554b07ad7c392491dba6daf25eef1332a22e8
FROM ${BASE_IMAGE}:${UBUNTU_VERSION}

ARG TIMEZONE="America/New_York"
ARG DOCKER_VERSION

# =========================================================================
# Install Python and misc utils
# =========================================================================
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        jq \
        python3 \
        python3-pip \
        python3-flake8 \
        python3-ipython \
        python3-pip \
        software-properties-common \
        tzdata \
        unzip \
        wget \
    && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND

# =========================================================================
# Install Docker client
# =========================================================================
RUN export DEBIAN_FRONTEND=noninteractive && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" \
        | gpg --dearmor -o "/etc/apt/keyrings/docker.gpg" \
    && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        docker-ce=${DOCKER_VERSION} \
        docker-ce-cli=${DOCKER_VERSION} \
        containerd.io \
        docker-compose-plugin \
    && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND
