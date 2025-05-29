# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# FIXME: Change from beta version to almalinux:10 later
ARG FROM=almalinux:10
FROM ${FROM}

COPY qemu-* /usr/bin/

ARG DEBUG

RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
  dnf install redhat-release -y && \
  dnf install --enablerepo=crb -y ${quiet} \
    make \
    gcc-c++ \
    ruby-devel  \
    rubygems \
    rubygem-rake \
    rubygem-bundler \
    libcap-ng-devel \
    libedit-devel \
    ncurses-devel \
    libyaml-devel \
    libffi-devel \
    git \
    cyrus-sasl-devel \
    nss-softokn-freebl-devel \
    pkg-config \
    rpm-build \
    rpmdevtools \
    redhat-rpm-config \
    openssl-devel \
    tar \
    zlib-devel \
    cmake \
    libarchive \
    # install which for building librdkafka 1.9.0 or later
    which && \
    # raise IPv4 priority
    echo "precedence ::ffff:0:0/96 100" > /etc/gai.conf && \
    # enable multiplatform feature
    gem install --no-document --install-dir /usr/share/gems bundler builder && \
  yum clean ${quiet} all && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
