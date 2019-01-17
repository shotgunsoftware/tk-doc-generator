[![Linting](https://img.shields.io/badge/PEP8%20by-Hound%20CI-a873d1.svg)](https://houndci.com)

# Toolkit Documentation Generator

This repository makes it easy to generate documentation for 
Shotgun Ecosystem and Toolkit related repositories.

## What does it do?

Integrate this repository as a submodule in a Toolkit App or other 
Shotgun App that benefits and it will:
 
- Convert any markdown in the `/docs` folder into multi-language html.
- Provide a consistent look and feel to build output.
- Convert any rst/sphinx files in the `/docs` folder into multi-language html.
- Automatically build and deploy documentation that is pushed to master.
- Automatically build S3 based previews for all commits in PRs.
- Allow you to run local (docker based) previews.
- Allow you to generate a full reference collection site, where sphinx/rst
  docs from multiple repositories are collected and generated as a single release.

### Tech info

- Sphinx is used to convert rst into markdown
- Jekyll is used to convert markdown into a html website


## Setting up doc generation

In order to use it for your repository, you need the following:
 
- Documentation (in markdown or rst form) located in a `/docs` folder.
- Add this repository as a submodule of your repo in the folder `/tk-doc-generator`.
- An S3 bucket set up for public web access if you want PR based previews.
- A location to deploy your target website. We recommend github pages and this
  is what the examples are based on. 
- [Travis](https://travis-ci.org) for CI. For more information about how to set this up,
  see the section below.


## Integrating with Travis CI

Once you have set up this repository as a submodule to your code, setting up 
travis CI or adding it to an existing CI is easy.

### Environment variables

The following environment variables can be defined:

- `DOC_URL` - The target url where released docs will go, e.g. `https://developer.shotgunsoftware.com`.
- `DOC_PATH` - The path where the released docs will go, e.g. `/dev-docs`. 

If you want pull request previews, you need to define the following:

- `S3_BUCKET` - the name of a publicly accessible S3 bucket, in website hosting mode, e.g. `mybucket`.
- `S3_WEB_URL` - the website url where the bucket can be accessed, e.g. `http://mybucket.s3-website.eu-west-2.amazonaws.com`.
- `AWS_S3_ACCESS_KEY` - AWS access key with permissions to put new items into the `S3_BUCKET`.
- `AWS_S3_ACCESS_TOKEN` - AWS access token with permissions to put new items into the `S3_BUCKET`.
- `GITHUB_TOKEN` - Github access token used to create a comment on the PR with a link to the built docs. 

### Folder locations

- Your documentation needs to be located in `/docs`.
- The build output will be generated in `/_build` (see travis example below).


### Example `.travis.yml` file

The following travis file illustrates how to integrate:

```yaml
# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

language: python

python:
    - "2.7"

cache:
  pip: true
  directories:
     # manually cache ruby dependencies
     - $TRAVIS_BUILD_DIR/tk-doc-generator/vendor/bundle

before_install:
  # required dependency for sphinx
  - sudo apt-get install -y pandoc

install:
  # 
  # install pyside - from https://stackoverflow.com/questions/24489588
  - sudo apt-get install libqt4-dev
  - pip install PySide --no-index --find-links https://parkin.github.io/python-wheelhouse/;
  - python ~/virtualenv/python${TRAVIS_PYTHON_VERSION}/bin/pyside_postinstall.py -install
  #
  # jekyll dependencies
  - bundle install --gemfile=./tk-doc-generator/Gemfile --deployment
  #
  # sphinx dependnecies
  - pip install -r ./tk-doc-generator/requirements.txt

script:
  # script that runs the CI and handles S3 previews
  - python ./tk-doc-generator/travis-generate-docs.py

deploy:
  # When commiting to master, auto-deploy to github-pages
  # This will copy the contents of the _build folder to gh-pages branch and push
- provider: pages
  local-dir: ./_build
  target-branch: gh-pages
  skip-cleanup: true
  github-token: $GITHUB_TOKEN
  on:
    # only do this when on the master branch
    branch: master
```

## Running locally

In order to run the setup manually, you need docker.
Simply use the `/preview_docs.sh` script located in the root folder of
this repo in order to build the documents. 

Note: For maintenance operations, a `/scripts/docker-bash.sh` script is handy.


