#!/bin/bash

set -eu -o pipefail

IMAGE_REPO="${IMAGE_REPO:-quay.io/adambkaplan/shipwright-io}"
TAG="${TAG:-2024-devconf-us}"
PLATFORM="${PLATFORM:-all}"
TMPDIR="${TMPDIR:-/tmp/build-with-ko}"
PODMAN="${PODMAN:-podman}"

source ../lib/demo-magic.sh

rm -rf "${TMPDIR}"
mkdir -p "${TMPDIR}"

pushd ~/go/src/github.com/shipwright-io/build > /dev/null

clear

p "Ko is a tool for building and deploying Go applications."
p "It is specialized for Go, and uses the SDK's cross-platform compiler to build multi-arch images."
p "Let's use ko to make images for the Shipwright Build project!"

pe "pwd && ls"

pe "ko \
version"

wait
clear

p "Let's build!"

cmd

# Run ko resolve these commands
# KO_DOCKER_REPO="${IMAGE_REPO}" ko resolve \
#   --base-import-paths \
#   --recursive \
#   --tags "${TAG}" \
#   --platform "${PLATFORM}" \
#   --filename deploy/ > "${TMPDIR}/release.yaml"

popd > /dev/null

p "The build is now complete, and we have a YAML manifest that can be deployed on Kubernetes."
wait
clear

p "Let's look at the digests that were produced."
pe "grep ${IMAGE_REPO} ${TMPDIR}/release.yaml"
p "And if we inspect the manifest, we see the individual images."
pe "${PODMAN} manifest inspect ${IMAGE_REPO}/shipwright-build-controller:${TAG}"

p "Voila! A manifest list with our multi-arch Go application!"
