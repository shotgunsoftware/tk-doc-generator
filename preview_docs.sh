#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

set -eu -o pipefail


ARG1="${1:-}"
case "${ARG1}" in
    -h|--help)
        cat << EOF
Usage:  preview_docs.sh [--rebuild|-h] [URL_PATH]

Builds a local preview of the documentation in the parent repository that
includes tk-doc-generator as a sub-module.

Options:
    --rebuild       Force re-build docker image. By default (for speed),
                    it will only build a new Docker image if one doesn't exist.
    -h, --help      Print this help and exit 0.
    URL_PATH        Explicit URL sub folder/path to host under.
                    By default, it's automatically calculated in order:
                    1. DOC_PATH=/* in .travis.yml
                    2. Current folder name

Environment variables:
    IMAGE_TAG:
        Tag for the image Docker builds.
        Defaults "tk-doc-generator" if not set

    MOUNT_TO:
        Destination directory which the parent directory this script,
        the folder above tk-doc-generator, is mounted to in the container.
        Defaults "/app" if not set

Examples:
    Typically, this command is run in the parent repository that includes
    tk-doc-generator as a sub-module.

    To force an image rebuild by running before creating documentation:

        tk-doc-generator/preview_docs.sh --rebuild

    Some environment variables will also influence this script's behaviour.
    For example, you can run the script like this to build/run the docker image
    tagged "my-doc-generator", you can run:

        IMAGE_TAG="my-doc-generator" tk-doc-generator/preview_docs.sh

EOF
        exit
    ;;
esac

# Setup useful directory variables for current script's folder/parent folder
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# Build if image does not exist OR first argument is --rebuild
IMAGE_TAG="${IMAGE_TAG:-tk-doc-generator}"
if [ -z "$(docker images --quiet ${IMAGE_TAG})" -o "${ARG1}" == "--rebuild" ]
then
    docker build --tag "${IMAGE_TAG}" ${THIS_DIR}
    shift  # Process remaining arg as explicit URL_PATH
else
    echo "'${IMAGE_TAG}' docker image already built"
    echo "To force a re-build, try running this script with --rebuild flag"
    echo
fi


# Setup mount/volume flags depending on which one current docker supports
MOUNT_TO="${MOUNT_TO:-/app}"
if ( docker run --help | grep --quiet -- --mount )
then
    MOUNT_FLAGS='--mount '"type=bind,source=$(pwd),target=${MOUNT_TO}"
else
    MOUNT_FLAGS='-v '"$(pwd):${MOUNT_TO}"
fi


# Finally, perform the document generation in container
EXPOSED_PORT="4000"
URL_PATH="${1:-$(
    grep -oP '(?<=DOC_PATH=/)[a-zA-Z0-9][a-zA-Z0-9_.-]*' $(pwd)/.travis.yml \
    || basename $(pwd)
)}"

if (echo "${URL_PATH}" | grep -qP '^[a-zA-Z0-9][a-zA-Z0-9_.-]*$')
then
    CONTAINER_NAME="${URL_PATH}-${EXPOSED_PORT}"
    until docker run --rm -d \
            --hostname="${CONTAINER_NAME}" \
            --name="${CONTAINER_NAME}" \
            -p "${EXPOSED_PORT}:${EXPOSED_PORT}" \
            -e EXPOSED_PORT="${EXPOSED_PORT}" \
            -e URLPATH="/${URL_PATH}" \
            -e SOURCE="${MOUNT_TO}/docs" \
            -e OUTPUT="${MOUNT_TO}/_build" \
            ${MOUNT_FLAGS} \
            ${IMAGE_TAG}
    do
        EXPOSED_PORT="$(( EXPOSED_PORT + 1 ))"
        CONTAINER_NAME="${URL_PATH}-${EXPOSED_PORT}"
    done
else
    echo "Invalid URL_PATH to host as: '${URL_PATH}'"
    echo 'It must only contain these characters: [a-zA-Z0-9_.-]'
    echo
    echo 'Please either:'
    echo '1. Set a valid DOC_PATH=/something in $(pwd)/.travis.yml, where that'
    echo '   something must only contain those valid characters:  e.g.'
    echo
    echo "       env:"
    echo "         global:"
    echo "             - DOC_PATH=/tk-amazing-tool"
    echo
    echo "2. Rename current folder to only contain those valid characters."
    echo
    echo "3. Explicitly provide a valid URL_PATH to create under, e.g."
    echo
    echo "       preview_docs.sh tk-amazing-tool"
    echo
    echo
    URL_PATH=''
    while true
    do
        CONTAINER_ID=$(docker run --rm -d \
                -p "${EXPOSED_PORT}:${EXPOSED_PORT}" \
                -e EXPOSED_PORT="${EXPOSED_PORT}" \
                -e URLPATH="/" \
                -e SOURCE="${MOUNT_TO}/docs" \
                -e OUTPUT="${MOUNT_TO}/_build" \
                ${MOUNT_FLAGS} \
                ${IMAGE_TAG}) \
            && break \
            || EXPOSED_PORT="$(( EXPOSED_PORT + 1 ))"
    done
    CONTAINER_NAME=$(docker ps -f id=${CONTAINER_ID} --format '{{.Names}}')
fi

# Directly calling log follow here to show any errors in serve_docs.sh
docker logs --follow ${CONTAINER_NAME}