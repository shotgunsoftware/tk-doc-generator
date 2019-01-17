# Copyright 2019 Autodesk, Inc.  All rights reserved.
#
# Use of this software is subject to the terms of the Autodesk license agreement
# provided at the time of installation or download, or which otherwise accompanies
# this software in either electronic or hard copy form.
#

# dockerfile to spin up a container suitable for generation of documentation

FROM centos:7
LABEL maintainer="toolkit@shotgunsoftware.com>"

#
# Build
#

# Install build packages
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y \
    # Generic build packages
    autoconf \
    automake \
    gcc \
    gcc-c++ \
    git \
    libtool \
    make \
    nasm \
    perl-devel \
    zlib-devel \
    tar \
    nc \
    xz \
    # sphinx
    pandoc \
    # Python libs
    python-pip \
    # Ruby
    libyaml-devel \
    openssl-devel \
    libreadline-dev \
    zlib-devel \
    python-pyside \
    yum clean all

# Ruby
ENV RUBY_MAJOR_VER=2.5 \
    RUBY_VER=2.5.3 \
    PATH=/opt/ruby-2.5/bin:$PATH
RUN DIR=$(mktemp -d) && cd ${DIR} && \
    curl -OLs http://ftp.ruby-lang.org/pub/ruby/ruby-$RUBY_VER.tar.gz  && \
    tar xzf ruby-$RUBY_VER.tar.gz && \
    cd ruby-$RUBY_VER && \
    ./configure --prefix=/opt/ruby-${RUBY_VER} --bindir=/opt/ruby-${RUBY_VER}/bin --disable-install-doc && \
    make -j 8 && \
    make install && \
    make distclean && \
    rm -rf ${DIR} && \
    cd /opt/ && ln -sfn ruby-${RUBY_VER} ruby-${RUBY_MAJOR_VER}

RUN mkdir -p /app
WORKDIR /app

COPY ./Gemfile /app
COPY ./Gemfile.lock /app
COPY ./requirements.txt /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# note: stay on bundler 1.17 to be travis compatible
RUN gem install bundler -v 1.17.2 --no-document
RUN bundle config --global jobs 7
RUN bundle install







