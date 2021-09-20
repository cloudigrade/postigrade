#!/bin/bash

# Make job happy\
mkdir -p artifacts
cat << EOF > artifacts/junit-dummy.xml
<testsuite tests="1">
    <testcase classname="dummy" name="dummytest"/>
</testsuite>
EOF

# Actual PR Check
IMAGE_NAME="quay.io/cloudservices/postigrade"
IMAGE_TAG=$(git rev-parse --short=7 HEAD)
DOCKER_CONF="${PWD}/.docker"

if [[ -z "$QUAY_USER" || -z "$QUAY_TOKEN" ]]; then
    echo "QUAY_USER and QUAY_TOKEN must be set"
    exit 1
fi

if [[ -z "$RH_REGISTRY_USER" || -z "$RH_REGISTRY_TOKEN" ]]; then
    echo "RH_REGISTRY_USER and RH_REGISTRY_TOKEN  must be set"
    exit 1
fi

mkdir -p "${DOCKER_CONF}"

# Log into the registries
docker --config="${DOCKER_CONF}" login -u="${QUAY_USER}" -p="${QUAY_TOKEN}" quay.io
docker --config="${DOCKER_CONF}" login -u="$RH_REGISTRY_USER" -p="$RH_REGISTRY_TOKEN" registry.redhat.io
# Pull 'Latest' Image
docker --config="${DOCKER_CONF}" pull ${IMAGE_NAME}:latest || true
# Build
docker --config="${DOCKER_CONF}" build --cache-from ${IMAGE_NAME}:latest .
