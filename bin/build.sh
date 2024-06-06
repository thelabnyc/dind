#!/usr/bin/env bash

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


# Build image
echoAndRun docker build \
    --pull \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
    --build-arg DOCKER_VERSION="$DOCKER_VERSION" \
    --tag "${CI_REGISTRY_IMAGE:-dind}:${OUTPUT_TAG_NAME}" \
    .

docker push "${CI_REGISTRY_IMAGE:-dind}:${OUTPUT_TAG_NAME}"

for TAG in $EXTRA_TAGS
do
    docker tag "${CI_REGISTRY_IMAGE:-dind}:${OUTPUT_TAG_NAME}" "${TAG}"
    docker push "${TAG}"
done
