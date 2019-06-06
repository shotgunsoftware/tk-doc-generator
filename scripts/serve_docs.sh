#!/bin/bash
# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# Usage: serve_docs.sh
#
# Build and serve documentation using "jekyll serve".
#
# Although this script does not take in arguments directly, certain environment
# variables do change certain settings and paths.
#
# Environment Variables:
#
#   SOURCE:         Directory to look for documentation to generate from.
#                   Defaults to current working directory
#                   (e.g. from "docker run -w DIR DOCKER_IMAGE")
#
#   OUTPUT:         Directory to output generated HTML and assets in.
#                   Defaults to "_site" folder under current working directory.
#
#   EXPOSED_PORT:   Port on host to expose website from.
#                   Defaults to 4000.
#
#   URLPATH:        Base directory (under root/domain) to host site on.
#                   Defaults to /, which resolves to domain root
#                   e.g. "localhost:4000/".
#

# exit on error
set -eu -o pipefail

SOURCE=${SOURCE:-$(pwd)}
OUTPUT=${OUTPUT:-$(pwd)/_site}
EXPOSED_PORT=${EXPOSED_PORT:-4000}
URLPATH=${URLPATH:-/}
echo "---------------------------------------------------"
echo "Shotgun Ecosystem Documentation Build Process"
echo "---------------------------------------------------"
echo "          Source: ${SOURCE}"
echo "          Output: ${OUTPUT}"
echo " URL (localhost): $(hostname -I):${EXPOSED_PORT}/${URLPATH}"
echo "---------------------------------------------------"

# contains Gemfile, jekyll, etc
TK_DOC_GEN_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"
OUR_REPO_ROOT="$(readlink -m ${SOURCE}/..)"  # Typically user's project root folder

TMP_FOLDER="${TK_DOC_GEN_SRC}/_doc_generator_tmp"
TMP_BUILD_FOLDER="${TMP_FOLDER}/markdown_src"

echo
echo "Cleaning out and creating new internal build location '${TMP_FOLDER}'..."
rm -rf ${TMP_FOLDER}
mkdir -p ${TMP_FOLDER}

echo "Cleaning out final build location '${OUTPUT}'..."
rm -rf ${OUTPUT}

echo "Synlinking source files into '${TMP_BUILD_FOLDER}'..."
# In case build_sphinx.py generates additional junk that's not part of SOURCE/*
for SRC_PATH in ${SOURCE}/*
do
    ln -rsf ${SRC_PATH} ${TMP_BUILD_FOLDER}
done

echo "Running Sphinx RST -> Markdown build process..."
build_sphinx.py ${TMP_BUILD_FOLDER}

# Setup additional plugin paths
PLUGINS="${TK_DOC_GEN_SRC}/jekyll/_plugins"
EXTRA_PLUGIN=${TMP_BUILD_FOLDER}/_plugins
if [ -d "${EXTRA_PLUGIN}" ]
then
    echo "Using additional plugins from ${EXTRA_PLUGIN}..."
    PLUGINS="${PLUGINS},${EXTRA_PLUGIN}"
fi

# Setup additional config overrides
CONFIGS="${TK_DOC_GEN_SRC}/jekyll/_config.yml"
OVERRIDE_CONFIG=${OUR_REPO_ROOT}/jekyll_config.yml
if [ -e "${OVERRIDE_CONFIG}" ]
then
    echo "Using override config from ${OVERRIDE_CONFIG}..."
    CONFIGS="${CONFIGS},${OVERRIDE_CONFIG}"
fi

echo "Running Jekyll to generate html from markdown..."
echo "---------------------------------------------------"
umask 0000
BUNDLE_GEMFILE=${TK_DOC_GEN_SRC}/Gemfile JEKYLL_ENV=production \
    # --detach \
bundle exec jekyll serve \
    --detach \
    --baseurl "${URLPATH}" \
    --host $(hostname -I) --port "${EXPOSED_PORT}" \
    --trace \
    --config "${CONFIGS}" \
    --plugins "${PLUGINS}" \
    --source "${TMP_BUILD_FOLDER}" \
    --destination "${OUTPUT}"

# Setup URLPATH for localhost formatting ("docker logs" strips empty lines)
URLPATH="${URLPATH#/}"
cat << EOF
###########################################################################
#
#  Documentation built. Open in web-browser:
#  http://localhost:${EXPOSED_PORT}/${URLPATH}${URLPATH:+/}
#
###########################################################################
|
|>> This terminal is currently viewing the live log.
|   CTRL+C to exit viewing this log.
|
|>> You may also want to run this every now and then if you have rst files:
|   docker exec $(hostname) build_sphinx.py ${TMP_BUILD_FOLDER}
|
---------------------------------------------------------------------------
|
|   To ACTUALLY stop the jekyll server running in Docker:
|   docker stop $(hostname)
|
---------------------------------------------------------------------------
EOF
while pgrep -f jekyll &> /dev/null
do
    sleep 2s
done