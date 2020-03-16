# td-agent-builder

## Prerequisites

### For building .rpm & .deb packages

  * Any host OS that is supported by Docker
    * Debian buster or Ubuntu 18.04 are recommended
  * [Docker](https://docs.docker.com/install/)
  * Ruby 2.2 or later
  * Git

### For building Windows package (.msi)

  * Windows OS (10 or 2019 are verified)
  * [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
    * You need to switch to "Windows containers" before using it.
  * [RubyInstaller](https://rubyinstaller.org/) 2.2 or later.
  * [Git for Windows](https://gitforwindows.org/)

If you want to build it without Docker, you need to setup additional prerequisites by your self. See [Dockerfile for Windows](td-agent/msi/Dockerfile) for more detail.

## How to build .rpm package

```console
% rake yum:build
```

## How to build .deb package

```console
% rake apt:build
```

## How to build .msi package

```console
% rake msi:build
```

or if you don't use Docker:

```console
% rake msi:selfbuild
```
