#!/usr/bin/env bash

set -euxo pipefail

# Derive OUTPUT_TAG_NAME from UBUNTU_VERSION if not already set
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
