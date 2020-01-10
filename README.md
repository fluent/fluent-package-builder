# td-agent-builder

## Prerequisites

* Docker
* Ruby
* Bundler

## Setup

```console
% bundle install --path vendor/bundle
```

## How to build .rpm packages

```console
% bundle exec rake yum
```

## How to build .deb packages

```console
% bundle exec rake apt
```
