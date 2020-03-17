#!/usr/bin/env bash

set -e

GENERIC_BIN_DIR="/usr/local/bin"

## Generic stuff
apt-get -qq update
apt-get -qq install curl wget

## Install Operator-SDK
if [[ ! -x "$(command -v operator-sdk)" ]]; then
    OPERATOR_SDK_VERSION="0.15.2"
    OPERATOR_SDK_BIN="${GENERIC_BIN_DIR}/operator-sdk"

    wget -q \
        "https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_SDK_VERSION}/operator-sdk-v${OPERATOR_SDK_VERSION}-x86_64-linux-gnu" \
        -O "${OPERATOR_SDK_BIN}"
    chmod +x "${OPERATOR_SDK_BIN}"
fi

## Install Helm
if [[ ! -x "$(command -v helm)" ]]; then
    export HELM_INSTALL_DIR="${GENERIC_BIN_DIR}"
    HELM_BIN="${GENERIC_BIN_DIR}/helm"

    curl -sS -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    chmod +x ${HELM_BIN}
fi

## Install Docker-CE
if [[ ! -x "$(command -v docker)" ]]; then
    curl -sS -L https://get.docker.com/ | bash
fi