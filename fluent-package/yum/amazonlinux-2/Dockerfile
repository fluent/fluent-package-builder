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

ARG FROM=amazonlinux:2
FROM ${FROM}

COPY qemu-* /usr/bin/

ARG DEBUG

RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
  yum update -y ${quiet} && \
  yum install -y ${quiet} yum-utils yum-config-manager && \
  yum-config-manager --enable epel && \
  yum groupinstall -y ${quiet} "Development Tools" && \
  yum install -y ${quiet} \
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
    rpmlint \
    cmake3 \
    # install which for building librdkafka 1.9.0 or later
    which && \
  amazon-linux-extras install ruby3.0 && \
  # raise IPv4 priority
  echo "precedence ::ffff:0:0/96 100" > /etc/gai.conf && \
  # enable multiplatform feature (bundler 2.4.22 is the latest version which supports ruby 2.6)
  gem install --no-document bundler:2.4.22 builder && \
  yum clean ${quiet} all && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
