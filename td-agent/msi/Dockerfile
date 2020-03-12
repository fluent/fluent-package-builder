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

# The "servercore" image cannot install DotNet3.5 (which is required by
# wixtoolset) by chocolatey.
#ARG FROM=mcr.microsoft.com/windows/servercore:ltsc2019
ARG FROM=mcr.microsoft.com/dotnet/framework/runtime:3.5
FROM ${FROM}

# Install Chocolatey to set up toolchain
RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install toolchain
RUN \
  choco install -y git wixtoolset 7zip && \
  choco install -y msys2 --params /NoUpdate && \
  choco install -y ruby --version 2.5.1.2 && \
  refreshenv && \
  ridk install 3 && \
  gem install bundler
