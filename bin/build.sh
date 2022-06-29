#!/usr/bin/env sh

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Echo the a command, then run it. Useful for debugging CI to see what command
# is causing what output.
echoAndRun () {
    echo -e "${GREEN}$*${NC}"
    "$@"
}

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


# Create a buildx instance if one doesn't already exist
if [ "$(docker buildx ls | grep docker-container  | wc -l)" -le "0" ]; then
    echoAndRun docker buildx create --use;
fi

CACHE_FROM=""
if [ ! -z "$CI_REGISTRY_IMAGE" ]; then
    CACHE_FROM="--cache-from \"${CI_REGISTRY_IMAGE}:${OUTPUT_TAG_NAME}\""
fi


# Build image
echoAndRun docker buildx build \
    --platform "$PLATFORMS" \
    --pull \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
    --build-arg DOCKER_VERSION="$DOCKER_VERSION" \
    --build-arg COMPOSE_VERSION="$COMPOSE_VERSION" \
    $CACHE_FROM \
    --tag "${CI_REGISTRY_IMAGE:-dind}:${OUTPUT_TAG_NAME}" \
    $EXTRA_BUILD_ARGS \
    .
