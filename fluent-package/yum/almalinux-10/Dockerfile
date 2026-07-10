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
ARG FROM=almalinux:10.0
FROM ${FROM}

COPY qemu-* /usr/bin/
COPY almalinux-vault-10.0.repo /etc/yum.repos.d/

ARG DEBUG

# Keep compatibility with older RHEL 10.x, hold on specific version
# not to introduce GLIBC_2.40, OPENSSL_3.3.0, OPENSSL_3.4.0, OPENSSL_3.5.0
RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
  dnf install redhat-release -y && \
  dnf install --enablerepo=crb -y ${quiet} \
    make \
    gcc-c++-14.3.1-4.4.el10.alma.2 \
    ruby-devel-3.3.8-10.el10_0  \
    rubygems-3.5.22-10.el10_0 \
    rubygem-rake-13.1.0-10.el10_0 \
    rubygem-bundler-2.5.22-10.el10_0 \
    libcap-ng-devel \
    libedit-devel \
    ncurses-devel \
    libyaml-devel \
    libffi-devel \
    git \
    cyrus-sasl-devel \
    nss-softokn-freebl-devel \
    pkg-config \
    rpm-build-4.19.1.1-12.el10.alma.1 \
    rpmdevtools \
    redhat-rpm-config \
    openssl-libs-3.2.2-16.el10_0.4.alma.1 \
    openssl-devel-3.2.2-16.el10_0.4.alma.1 \
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
