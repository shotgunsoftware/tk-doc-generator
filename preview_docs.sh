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
Usage:  preview_docs.sh [--rebuild|-h]

Builds a local preview of the documentation in the parent repository that
includes tk-doc-generator as a sub-module.

Options:
    --rebuild       Force re-build docker image. By default (for speed),
                    it will only build a new Docker image if one doesn't exist.
    -h, --help      Print this help and exit 0.

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
docker run --rm \
    ${MOUNT_FLAGS} \
    ${IMAGE_TAG} \
    --url="http://localhost" \
    --url-path="$(pwd)/_build" \
    --source="${MOUNT_TO}/docs" \
    --output="${MOUNT_TO}/_build"

echo "Documentation built. Open in web-browser: $(pwd)/_build/index.html"
