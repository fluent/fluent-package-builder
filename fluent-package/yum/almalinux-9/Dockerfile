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

ARG FROM=almalinux:9.2
FROM ${FROM}

COPY qemu-* /usr/bin/
COPY almalinux-vault-9.2.repo /etc/yum.repos.d/almalinux-vault-9.2.repo

ARG DEBUG

RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
  dnf install redhat-release -y && \
  dnf install --enablerepo=crb -y ${quiet} \
    make \
    gcc-c++-11.3.1-4.3.el9.alma \
    glibc-devel-2.34-60.el9_2.7 \
    ruby-devel-3.0.4-160.el9_0 \
    rubygems-3.2.33-160.el9_0 \
    rubygem-rake-13.0.3-160.el9_0 \
    rubygem-bundler-2.2.33-160.el9_0 \
    libcap-ng-devel \
    libedit-devel \
    ncurses-devel \
    libyaml-devel \
    libffi-devel \
    git \
    cyrus-sasl-devel \
    nss-softokn-freebl-devel \
    pkg-config \
    rpm-build-4.16.1.3-22.el9 \
    rpmdevtools \
    redhat-rpm-config \
    openssl-devel-3.0.7-17.el9_2 \
    tar \
    zlib-devel \
    rpmlint \
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
