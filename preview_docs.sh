#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# Builds a local preview of the documentation in the parent repository that is
# including tk-doc-generator as a submodule.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build ${THIS_DIR}/../tk-doc-generator -t tk-doc-generator && \
docker run --mount type=bind,source="${THIS_DIR}/..",target=/app tk-doc-generator \
/app/tk-doc-generator/scripts/build_docs.sh --url=http://localhost --url-path=${THIS_DIR}/../_build --source=/app/docs --output=/app/_build && \
echo "Documentation built in ${THIS_DIR}/../_build/index.html"
