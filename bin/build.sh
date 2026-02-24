#!/usr/bin/env bash

set -euxo pipefail

# Function for loading vars from a .env file
# See https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
loadEnv () {
    local envFile="${1?Missing environment file}"
    local environmentAsArray variableDeclaration
    mapfile environmentAsArray < <(
        grep --invert-match '^#' "${envFile}" \
            | grep --invert-match '^\s*$'
    ) # Uses grep to remove commented and blank lines
    for variableDeclaration in "${environmentAsArray[@]}"; do
        export "${variableDeclaration//[$'\r\n']}" # The substitution removes the line breaks
    done
}

# Load env vars from .env file (if one exists)
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    loadEnv "$ENV_FILE"
fi

# Derive OUTPUT_TAG_NAME from UBUNTU_VERSION if not already set (e.g. from .env)
if [ -z "${OUTPUT_TAG_NAME:-}" ]; then
    UBUNTU_SHORT_VERSION="${UBUNTU_VERSION%%@*}"
    if [ -n "${CI_PIPELINE_IID:-}" ]; then
        OUTPUT_TAG_NAME="${UBUNTU_SHORT_VERSION}.${CI_PIPELINE_IID}"
    else
        OUTPUT_TAG_NAME="${UBUNTU_SHORT_VERSION}"
    fi
fi

# When ARCH is set (CI), append it as a suffix to the tag
ARCH_SUFFIX=""
if [ -n "${ARCH:-}" ]; then
    ARCH_SUFFIX="-${ARCH}"
fi

IMAGE_TAG="${CI_REGISTRY_IMAGE:-dind}:${OUTPUT_TAG_NAME}${TAG_SUFFIX:-}${ARCH_SUFFIX}"

# Build image
docker build \
    --pull \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
    --build-arg DOCKER_VERSION="$DOCKER_VERSION" \
    --tag "$IMAGE_TAG" \
    .

if [ -n "${CI_COMMIT_BRANCH:-}" ] && [ "$CI_COMMIT_BRANCH" == "${CI_DEFAULT_BRANCH:-}" ]; then
    docker push "$IMAGE_TAG"
fi
