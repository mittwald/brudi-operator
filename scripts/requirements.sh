#!/usr/bin/env bash

set -e

GENERIC_BIN_DIR="/usr/local/bin"

## Generic stuff
sudo apt-get -qq update
sudo apt-get -qq install curl wget git

## Install Operator-SDK
if [[ ! -x "$(command -v operator-sdk)" ]]; then
    OPERATOR_SDK_VERSION="0.15.2"
    OPERATOR_SDK_BIN="${GENERIC_BIN_DIR}/operator-sdk"

    sudo wget -q \
        "https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_SDK_VERSION}/operator-sdk-v${OPERATOR_SDK_VERSION}-x86_64-linux-gnu" \
        -O "${OPERATOR_SDK_BIN}"
    sudo chmod +x "${OPERATOR_SDK_BIN}"
fi

## Install Helm
if [[ ! -x "$(command -v helm)" ]]; then
    export HELM_INSTALL_DIR="${GENERIC_BIN_DIR}"
    HELM_BIN="${GENERIC_BIN_DIR}/helm"

    curl -sS -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    sudo chmod +x ${HELM_BIN}
fi

## Install Helm push
helm plugin install https://github.com/chartmuseum/helm-push.git

## Install Docker-CE
if [[ ! -x "$(command -v docker)" ]]; then
    curl -sS -L https://get.docker.com/ | sudo bash
fi
