ARG BASE_IMAGE=ubuntu
ARG UBUNTU_VERSION=26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944
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
        gpg \
        gpg-agent \
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

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.13.4@sha256:9f130421e930bfbdc563c00740466603f8723158e90297d07957c2294640262b /uv /uvx /bin/

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
    DOCKER_APT_VERSION=$(apt-cache madison docker-ce | awk -v ver="$DOCKER_VERSION" '$3 ~ ver {print $3; exit}') && \
    test -n "$DOCKER_APT_VERSION" || { echo "ERROR: No docker-ce package found matching ${DOCKER_VERSION}"; exit 1; } && \
    apt-get install -yq --no-install-recommends \
        docker-ce="${DOCKER_APT_VERSION}" \
        docker-ce-cli="${DOCKER_APT_VERSION}" \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND

# =========================================================================
# Install Mise
# =========================================================================
RUN export DEBIAN_FRONTEND=noninteractive && \
    install -dm 755 /etc/apt/keyrings && \
    wget -qO - "https://mise.jdx.dev/gpg-key.pub" \
        | gpg --dearmor -o "/etc/apt/keyrings/mise-archive-keyring.gpg" \
    && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" \
        > /etc/apt/sources.list.d/mise.list \
    && \
    apt-get update && \
    apt-get install -y mise && \
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND
