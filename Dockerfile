FROM docker.io/library/ubuntu:jammy

RUN set -ex; \
    useradd -m -u 9999 codewarrior; \
    mkdir -p /workspace; \
    chown -R codewarrior: /workspace;

RUN set -ex; \
    apt-get update;

USER codewarrior

WORKDIR /workspace

RUN set -ex; \
    cd /workspace;
