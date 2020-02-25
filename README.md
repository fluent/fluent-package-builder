# td-agent-builder

## Prerequisites

### For building .rpm & .deb packages

  * [Docker](https://docs.docker.com/install/)
  * Ruby

### For building Windows (.msi) package

  * Windows OS
  * Ruby
    * [RubyInstaller](https://rubyinstaller.org/) 2.4.* or 2.5.* are recommended.
  * [WiX Toolset](https://wixtoolset.org/)
  * [Git for Windows](https://gitforwindows.org/)
  * [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (optional)
    If you use Docker, you don't need to install other prerequisites except Ruby.

If you don't use Docker, you need to set up build environment manually by the following commands:

```
% ridk install 3
% gem install bundler
```

See also [Dockerfile for Windows](td-agent/msi/Dockerfile).

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

or if you use Docker:

```console
% rake msi:docker
```
