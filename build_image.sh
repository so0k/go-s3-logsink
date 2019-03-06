#!/bin/bash
set -x

IMAGE_NAME=go-s3-logsink
REPOSITORY_NAMESPACE=${1:-swatrider}
TAG=${2:-latest}

REPOSITORY="${REPOSITORY_NAMESPACE}/${IMAGE_NAME}"

docker build \
    -t "${REPOSITORY}:${TAG}" \
    -f Dockerfile .

docker push "${REPOSITORY}"
