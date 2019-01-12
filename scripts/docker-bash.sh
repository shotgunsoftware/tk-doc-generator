#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# Utility script that opens a bash prompt in the docker environment

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build ${THIS_DIR}/.. -t tk-doc-generator && \
docker run -it --mount type=bind,source="${THIS_DIR}/../..",target=/app tk-doc-generator bash
