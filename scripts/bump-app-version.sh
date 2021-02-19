#!/usr/bin/env bash

set -e

## debug if desired
if [[ -n "${DEBUG}" ]]; then
    set -x
fi

## make this script a bit more re-usable
GIT_REPOSITORY="github.com/mittwald/brudi-operator.git"
CHART_YAML="./deploy/helm-chart/brudi-operator/Chart.yaml"

## convert chart-variables to absolute pathing
CHART_YAML="$(readlink -f "${CHART_YAML}")"
CHART_PATH="$(dirname "${CHART_YAML}")"

## avoid noisy shellcheck warnings
TAG="${GITHUB_REF:10}"
[[ -n "${TAG}" ]] || TAG="0.0.0"
GITHUB_TOKEN="${GITHUB_TOKEN:-dummy}"

## temp working vars
TIMESTAMP="$(date +%s )"
TMP_DIR="/tmp/${TIMESTAMP}"

## set up Git-User
git config --global user.name "Mittwald Machine"
git config --global user.email "opensource@mittwald.de"

## temporary clone git repository
git clone "https://${GIT_REPOSITORY}" "${TMP_DIR}"
cd "${TMP_DIR}"

## replace appVersion
sed -i "s#appVersion:.*#appVersion: ${TAG}#g" "${CHART_YAML}"

## replace chart version with current tag without 'v'-prefix
sed -i "s#version:.*#version: ${TAG}#g" "${CHART_YAML}"

## useful for debugging purposes
git status

## Add new remote with credentials baked in url
git remote add publisher "https://mittwald-machine:${GITHUB_TOKEN}@${GIT_REPOSITORY}"

## add and commit changed file
git add -A

## useful for debugging purposes
git status

## stage changes
git commit -m "Bump chartVersion and appVersion to '${TAG}'"

## rebase
git pull --rebase publisher master

if [[ "${1}" == "publish" ]]; then

    ## publish changes
    git push publisher master

    ## upload chart
    helm repo add mittwald https://helm.mittwald.de
    helm push "${CHART_PATH}" mittwald

fi


exit 0
