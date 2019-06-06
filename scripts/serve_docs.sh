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

# Set defaults if no env vars detected
SOURCE=${SOURCE:-$(pwd)}
OUTPUT=${OUTPUT:-$(pwd)/_site}
EXPOSED_PORT=${EXPOSED_PORT:-4000}
URLPATH=${URLPATH:-/}

# contains Gemfile, jekyll, etc
TK_DOC_GEN_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"
OUR_REPO_ROOT="$(readlink -m ${SOURCE}/..)"  # Typically user's project root folder

echo "Cleaning out final build location '${OUTPUT}'..."
rm -rf ${OUTPUT}

echo "Running Sphinx RST -> Markdown build process..."
build_sphinx.py ${SOURCE}

# Setup additional plugin paths
PLUGINS="${TK_DOC_GEN_SRC}/jekyll/_plugins"
EXTRA_PLUGIN=${SOURCE}/_plugins
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
echo "          Source: ${SOURCE}"
echo "          Output: ${OUTPUT}"
echo "         Plugins: ${PLUGINS}"
echo "  Configurations: ${CONFIGS}"
echo " URL (localhost): localhost:${EXPOSED_PORT}${URLPATH}"
echo "---------------------------------------------------"
umask 0000
echo "$(hostname -I)localhost" >> /etc/hosts

# Auto-regeneration will be disabled if running server detached.
    # --verbose \
BUNDLE_GEMFILE=${TK_DOC_GEN_SRC}/Gemfile JEKYLL_ENV=production \
bundle exec jekyll serve \
    --baseurl "${URLPATH}" \
    --host localhost --port "${EXPOSED_PORT}" \
    --trace \
    --config "${CONFIGS}" \
    --plugins "${PLUGINS}" \
    --source "${SOURCE}" \
    --destination "${OUTPUT}"
