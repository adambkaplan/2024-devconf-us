#!/bin/bash

set -eu -o pipefail

IMAGE_REPO="${IMAGE_REPO:-quay.io/adambkaplan/sample-go-multiarch}"
VERSION="${VERSION:-0.1.0-devconf-us}"
PLATFORM="${PLATFORM:-all}"
PODMAN="${PODMAN:-podman}"

source ../lib/demo-magic.sh

pushd ~/go/src/github.com/adambkaplan/sample-go-multiarch > /dev/null

clear

p "Let's use ko to make a container image!"

pe "pwd && tree"
pe "make ko-build VERSION=${VERSION} PLATFORMS=${PLATFORM} IMAGE_TAG_BASE=${IMAGE_REPO}"

popd > /dev/null

p "Let's inspect the manifest with podman"
pe "${PODMAN} manifest inspect ${IMAGE_REPO}:v${VERSION}"

p "Voila! A manifest list with our multi-arch Go application!"
