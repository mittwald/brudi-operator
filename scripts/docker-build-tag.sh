#!/usr/bin/env bash

set -e

DOCKER_IMAGE="quay.io/mittwald/brudi-operator"
DOCKER_TAG="${1:-latest}"

IMAGE="${DOCKER_IMAGE}:${DOCKER_TAG}"

operator-sdk build "${IMAGE}"

if [[ -n "${PUSH}" && -n "${DOCKER_USER}" && -n "${DOCKER_PASSWORD}" ]]; then
    docker login -u="${DOCKER_USER}" -p="${DOCKER_PASSWORD}" quay.io
    docker push "${IMAGE}"
fi

exit 0