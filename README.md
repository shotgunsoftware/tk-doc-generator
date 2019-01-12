# Toolkit Documentation Generator

This repository handles standardized Shotgun developer doc site 
generation and CI integration. It has been designed to be added 
as a submodule to any repo where either sphinx or markdown 
doc generation or builds are desired.

## What do i need?

Just put your documentation in a `/docs` folder in your repository

## How does it work?

## Running locally

```
#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# starts up the docker container and runs the doc generation script

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build ${THIS_DIR}/../doc_builder -t tk-docs && \
docker run --mount type=bind,source="${THIS_DIR}/..",target=/app tk-docs \
/app/tk-doc-generator/scripts/build_docs.sh --url=http://localhost \
--url-path=${THIS_DIR}/../_build --source=/app/docs --output=/app/_build && \
echo "Documentation built in ${THIS_DIR}/../_build/index.html"
```


## Integrating with Travis CI





## Integrating with Github Pages