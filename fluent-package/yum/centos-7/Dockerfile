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

ARG FROM=ghcr.io/fluent/fluent-package-centos-7
FROM ${FROM}

## The following setting had used for initial building ghcr.io/fluent/fluent-package-centos-7.

# ARG FROM=centos:7
# FROM ${FROM}
#
# COPY qemu-* /usr/bin/
#
# ARG DEBUG
#
# RUN sed -i'' -e 's/^mirrorlist/#mirrorlist/g' \
#              -e 's/^#baseurl/baseurl/g' \
#              -e 's,mirror.centos.org/centos/$releasever,vault.centos.org/7.9.2009,g' \
#              /etc/yum.repos.d/CentOS-Base.repo
#
# RUN \
#   quiet=$([ "${DEBUG}" = "yes" ] || echo "--quiet") && \
#   yum update -y ${quiet} && \
#   yum install -y ${quiet} centos-release-scl && \
#   sed -i'' -e 's/^mirrorlist/#mirrorlist/g' \
#            -e 's/^# baseurl/baseurl/g' \
#            -e 's,mirror.centos.org/centos/7,vault.centos.org/7.9.2009,g' \
#            /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
#   sed -i'' -e 's/^mirrorlist/#mirrorlist/g' \
#            -e 's/^#baseurl/baseurl/g' \
#            -e 's,mirror.centos.org/centos/7,vault.centos.org/7.9.2009,g' \
#            /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
#   yum install -y ${quiet} epel-release && \
#   yum groupinstall -y ${quiet} "Development Tools" && \
#   yum install -y ${quiet} \
#     devtoolset-11 \
#     rh-ruby26-ruby-devel \
#     rh-ruby26-rubygems \
#     rh-ruby26-rubygem-rake \
#     rh-ruby26-rubygem-bundler \
#     libcap-ng-devel \
#     libedit-devel \
#     ncurses-devel \
#     libyaml-devel \
#     libffi-devel \
#     git \
#     cyrus-sasl-devel \
#     nss-softokn-freebl-devel \
#     pkg-config \
#     rpm-build \
#     rpmdevtools \
#     redhat-rpm-config \
#     openssl-devel \
#     tar \
#     zlib-devel \
#     rpmlint \
#     cmake3 && \
#   # raise IPv4 priority
#   echo "precedence ::ffff:0:0/96 100" > /etc/gai.conf && \
#   # enable multiplatform feature (bundler 2.4.22 is the latest version which supports ruby 2.6)
#   source /opt/rh/rh-ruby26/enable && gem install --no-document --install-dir /opt/rh/rh-ruby26/root/usr/share/gems bundler:2.4.22 builder && \
#   scl enable devtoolset-11 bash && \
#   yum clean ${quiet} all && \
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
