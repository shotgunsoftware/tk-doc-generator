#!/bin/bash

# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# exit on error
set -e

for i in "$@"
do
case $i in
    -u=*|--url=*)
    URL="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--url-path=*)
    URLPATH="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--source=*)
    SOURCE="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--output=*)
    OUTPUT="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

echo "---------------------------------------------------"
echo "DOC BUILD"
echo "Source = ${SOURCE}"
echo "Output = ${OUTPUT}"
echo "Url    = ${URL}${URLPATH}"
echo "---------------------------------------------------"

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TMP_FOLDER=${THIS_DIR}/../_build
TMP_BUILD_FOLDER=${TMP_FOLDER}/markdown_src
WEBSITE_FOLDER=${OUTPUT}

echo "cleaning out internal build location '${TMP_FOLDER}'..."
rm -rf ${TMP_FOLDER}

echo "cleaning out final build location '${WEBSITE_FOLDER}'..."
rm -rf ${WEBSITE_FOLDER}

echo "creating build location"
mkdir -p ${TMP_BUILD_FOLDER}

echo "copying markdown docs scaffold into build location"
cp -r ${SOURCE}/* ${TMP_BUILD_FOLDER}

# temp hack
export PYTHONPATH=/tmp/smb:$PYTHONPATH

echo "running sphinx builds..."
python ${THIS_DIR}/build_sphinx.py ${TMP_BUILD_FOLDER}

echo "building jekyll site"
BUNDLE_GEMFILE=${THIS_DIR}/../Gemfile JEKYLL_ENV=production \
bundle exec jekyll build \
--baseurl ${URLPATH} --config ${THIS_DIR}/../jekyll/_config.yml \
--source ${TMP_BUILD_FOLDER} --destination ${OUTPUT}


echo "------------------------------------------------------"
echo "Build completed."
echo "------------------------------------------------------"

