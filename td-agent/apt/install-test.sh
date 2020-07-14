#!/bin/bash

set -exu

apt update
apt install -V -y lsb-release

code_name=$(lsb_release --codename --short)
architecture=$(dpkg --print-architecture)
repositories_dir=/fluentd/td-agent/apt/repositories
case ${code_name} in
  xenial|bionic|focal)
    distribution=ubuntu
    channel=universe
    ;;
  buster)
    distribution=debian
    channel=main
    ;;
esac
apt install -V -y \
  ${repositories_dir}/${distribution}/pool/${code_name}/${channel}/*/*/*_${architecture}.deb

td-agent --version
