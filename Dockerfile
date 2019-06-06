# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# dockerfile to spin up a container suitable for generation of documentation
# - Gem/pip files used for setup are located in /usr/local/src
# - The default build_docs.sh is in /usr/local/src/scripts

FROM centos:7
LABEL maintainer="toolkit@shotgunsoftware.com"

#
# Build
#

# Install build packages
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y \
        # Generic build packages
        # autoconf, automake, gcc will be installed as libtool dependencies
        gcc-c++ \
        git \
        libtool \
        make \
        nasm \
        nc \
        perl-devel \
        # sphinx
        pandoc \
        # Python libs
        python-pip \
        python-pyside \
        # Ruby
        libreadline-dev \
        libyaml-devel \
        openssl-devel \
        zlib-devel && \
    yum clean all

# Ruby
ENV RUBY_MAJOR_VER=2.5 \
    RUBY_VER=2.5.3
ENV PATH=/opt/ruby-${RUBY_MAJOR_VER}/bin:$PATH
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -Ls http://ftp.ruby-lang.org/pub/ruby/ruby-${RUBY_VER}.tar.gz | \
        tar --strip-components=1 -xz && \
    ./configure \
        --prefix=/opt/ruby-${RUBY_VER} \
        --bindir=/opt/ruby-${RUBY_VER}/bin \
        --disable-install-doc && \
    make -j $(nproc) && \
    make install && \
    make distclean && \
    rm -rf ${DIR} && \
    cd /opt/ && ln -sfn ruby-${RUBY_VER} ruby-${RUBY_MAJOR_VER}

# Copy in any Gem/pip related files
WORKDIR /usr/local/src
COPY ./Gemfile .
COPY ./Gemfile.lock .
COPY ./requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# note: stay on bundler 1.17 to be travis compatible
RUN gem install bundler -v 1.17.2 --no-document && \
    bundle config --global jobs $(( $(nproc) - 1 )) && \
    bundle install

# Copy in and set "build_docs.sh" as default image executable for "docker run"
COPY ./jekyll jekyll
COPY ./scripts scripts
COPY ./sphinx sphinx
ENV PATH=${PATH}:/usr/local/src/scripts

# Install tk-core (python only)
RUN get-tk-core-packages.sh /usr/local/lib64/python
ENV PYTHONPATH=${PYTHONPATH}:/usr/local/lib64/python

RUN mkdir -vp _doc_generator_tmp/markdown_src
VOLUME [ "$(pwd)/_doc_generator_tmp/markdown_src" ]

ENTRYPOINT [ "serve_docs.sh" ]