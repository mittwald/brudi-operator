#!/usr/bin/env bash

set -e

DOCKER_IMAGE="quay.io/mittwald/brudi-operator"
DOCKER_TAG="${1:-latest}"

IMAGE="${DOCKER_IMAGE}:${DOCKER_TAG}"

operator-sdk build "${IMAGE}"

if [[ -n "${PUSH}" ]]; then
    docker push "${IMAGE}"
fi

exit 0