#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

set -eu -o pipefail

usage() {
cat << EOF
Usage:  get-tk-core-packages.sh [-h] FOLDER

Downloads the latest (tagged) version of tk-core into a given FOLDER.
If FOLDER does not exist, it will try create it.

Options:
    -h, --help      Print this help and exit 0

Example:
    To download the latest sgtk, tank and tank_vendor package folders into
    /usr/local/lib64/python, run:

        get-tk-core-packages.sh /usr/local/lib64/python

    This should result in a sgtk, tank and tank_vendor directly under
    /usr/local/lib64/python.
EOF
}

if [ $# -ne 1 ]
then
    echo 'ERROR: Please provide a folder to download/install into!'
    echo
    usage
    exit 1
fi

case $1 in
    -h|--help)
        usage
        exit
    ;;
esac

# Try create folder if it does not currently exist
FOLDER="$1"
[ -d "${FOLDER}" ] || mkdir -vp "${FOLDER}"

curl_untar() {
    # GitHub API to get all tags (seems to be latest first/at top of file)
    TAGS_FILE="$(mktemp)"
    curl -s "https://api.github.com/repos/shotgunsoftware/tk-core/tags" \
    | tee ${TAGS_FILE}

    # Grab first version (tag name), extract sgtk, tank and tank_vendor packages
    VERSION=$(grep --color=never -m 1 -o -P '(?<="name": ")[^"]+' ${TAGS_FILE})

    echo "Downloading and extracting tk-core ${VERSION} into: ${FOLDER}"
    curl -Ls https://github.com/shotgunsoftware/tk-core/archive/${VERSION}.tar.gz \
    | tar --directory "${FOLDER}" \
        --extract --gzip --file=- \
        --exclude='*tests*' --wildcards --wildcards-match-slash \
        --strip-components=2 '*python*'
}

temp_repo() {
    # Clone into a temporary directory
    TEMP_REPO="$(mktemp -d)"
    pushd "${TEMP_REPO}"
    git clone --no-checkout https://github.com/shotgunsoftware/tk-core.git .

    # Checkout latest version, grab the files/folders under python folder
    VERSION="$(git for-each-ref --sort=taggerdate --format '%(tag)' | tail -1)"
    echo "Cloned and extracting tk-core ${VERSION} into: ${FOLDER}"
    git checkout "${VERSION}"
    mv python/* "${FOLDER}"
    popd
}

# Try faster curl_untar first before falling back to temporary clone method
curl_untar || temp_repo
ls -lh "${FOLDER}"