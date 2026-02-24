#!/usr/bin/env bash

set -euxo pipefail

# Derive OUTPUT_TAG_NAME from UBUNTU_VERSION
UBUNTU_SHORT_VERSION="${UBUNTU_VERSION%%@*}"
OUTPUT_TAG_NAME="${UBUNTU_SHORT_VERSION}.${CI_PIPELINE_IID}"

SOURCE_AMD64="${CI_REGISTRY_IMAGE}:${OUTPUT_TAG_NAME}-amd64"
SOURCE_ARM64="${CI_REGISTRY_IMAGE}:${OUTPUT_TAG_NAME}-arm64"

MANIFEST_TAGS="${CI_REGISTRY_IMAGE}:${OUTPUT_TAG_NAME} thelab/dind:${OUTPUT_TAG_NAME}"
if [ "${IS_LATEST:-}" == "true" ]; then
    MANIFEST_TAGS="$MANIFEST_TAGS ${CI_REGISTRY_IMAGE}:latest thelab/dind:latest"
fi

for TAG in $MANIFEST_TAGS; do
    docker buildx imagetools create \
        --tag "$TAG" \
        "$SOURCE_AMD64" \
        "$SOURCE_ARM64"
done
