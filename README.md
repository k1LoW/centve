# centve

Virtual environments on CentOS using [anyenv](https://github.com/anyenv/anyenv)

## Usage

### Use as `container:` on GitHub Actions

``` yaml
name: CI

on:
  push:

jobs:
  test:
    name: Test using Ruby
    runs-on: ubuntu-latest
    container: ghcr.io/k1low/centve:latest
    steps:
      - name: Initialize anyenv and setup Ruby
        run: |
          anyenv-init
          rbenv global 2.7.2

      - name: Use Ruby
        run: |
          ruby -v
```

### Use as `FROM` in Dockerfile

**Ruby 3.0.0 on CentOS7**

``` dockerfile
FROM ghcr.io/k1low/centve:base

ENV RUBY_VERSION=3.0.0

RUN rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION
```

**Ruby 2.7.2 and PHP 5.6.40 on CentOS7**

``` dockerfile
FROM ghcr.io/k1low/centve:base

ENV RUBY_VERSION=2.7.2
ENV PHP_VERSION=5.6.40

RUN rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION
RUN phpenv install $PHP_VERSION && phpenv global $PHP_VERSION
```

## Language and Runtime

| Tag | Base image | Ruby | Perl | PHP |
| --- | --- | --- | --- | --- |
| `base` `7-base` | `centos:7` | - | - | - |
| `default` `7-default` `latest` | `centos:7` | `3.0` `2.7` | `5.32` | `8` `7` `5` |
