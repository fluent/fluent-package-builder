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

ARG FROM=centos:8
FROM ${FROM}

COPY qemu-* /usr/bin/

ARG DEBUG

RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
  sed -i 's|^mirrorlist|#mirrorlist|g' /etc/yum.repos.d/CentOS-*.repo && \
  sed -i 's|^#baseurl=http://mirror.centos.org/|baseurl=http://vault.centos.org/|g' /etc/yum.repos.d/CentOS-*.repo && \
  dnf install --enablerepo=powertools -y ${quiet} \
    make \
    gcc-c++ \
    ruby-devel  \
    rubygems \
    rubygem-rake \
    rubygem-bundler \
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
    rpmlint \
    cmake \
    libarchive && \
  # raise IPv4 priority
  echo "precedence ::ffff:0:0/96 100" > /etc/gai.conf && \
  # enable multiplatform feature
  gem install --no-document --install-dir /usr/share/gems bundler builder && \
  yum clean ${quiet} all && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
