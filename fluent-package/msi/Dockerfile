#
# fluent-package-builder
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

# The latest chocolatey requires .net 4.8, and wixtoolset requires .net 3.5,
# To satisfy both of them without reboot, use sdk image.
ARG FROM=mcr.microsoft.com/dotnet/framework/sdk:3.5-windowsservercore-ltsc2019
FROM ${FROM}

# Launch the following command as if cmd /S /C ...
SHELL ["cmd", "/S", "/C"]

# Install Chocolatey to set up toolchain
RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install toolchain
RUN \
  choco feature disable --name=showDownloadProgress && \
  choco install -y git wixtoolset 7zip && \
  # Required CMake 3.x to build cmetrics gem
  choco install -y cmake --version=3.31.6 --installargs 'ADD_CMAKE_TO_PATH=System' && \
  choco install -y msys2 --params /NoUpdate --version=20241208.0.0 && \
  choco install ruby -y --version=3.2.8.1 && \
  refreshenv && \
  ridk install 3 && \
  gem install --no-document --force bundler builder
