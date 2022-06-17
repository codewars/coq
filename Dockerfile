FROM docker.io/library/ubuntu:jammy AS builder

WORKDIR /tmp

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      wget ca-certificates curl build-essential unzip; \
    wget https://github.com/coq/platform/archive/refs/tags/2022.04.0.tar.gz; \
    tar xvf 2022.04.0.tar.gz; \
    rm -vf 2022.04.0.tar.gz;

WORKDIR /tmp/platform-2022.04.0

ENV OPAMROOT=/opt/coq \
    OPAMYES=1 \
    OCAML_VERSION=default \
    COQ_PLATFORM_EXTENT=b \
    COQ_PLATFORM_PACKAGE_PICK_FILE=package_picks/package-pick-8.15~2022.04.sh \
    COQ_PLATFORM_PARALLEL=p \
    COQ_PLATFORM_JOBS=4 \
    COQ_PLATFORM_SET_SWITCH=y

RUN set -ex; \
    echo "" > stdin; \
    echo "d" >> stdin; \
    ./coq_platform_make.sh < stdin;
