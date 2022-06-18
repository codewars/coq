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
    COQ_PLATFORM_EXTENT=f \
    COQ_PLATFORM_PACKAGE_PICK_FILE=package_picks/package-pick-8.15~2022.04.sh \
    COQ_PLATFORM_COMPCERT=n \
    COQ_PLATFORM_PARALLEL=p \
    COQ_PLATFORM_JOBS=4 \
    COQ_PLATFORM_SET_SWITCH=y

RUN set -ex; \
    echo "" > stdin; \
    echo "d" >> stdin; \
    ./coq_platform_make.sh < stdin;

ENV OPAM_SWITCH_NAME=__coq-platform.2022.04.0~8.15~2022.04
ENV OPAM_SWITCH_PREFIX=/opt/coq/$OPAM_SWITCH_NAME
ENV CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml \
    OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs/lib/toplevel \
    PATH=$OPAM_SWITCH_PREFIX/bin:$PATH

RUN set -ex; \
    cd /opt; \
    wget https://github.com/codewars/coq_codewars/archive/refs/tags/v2.0.0.tar.gz; \
    tar xvf v2.0.0.tar.gz; \
    rm -vf v2.0.0.tar.gz; \
    cd coq_codewars-2.0.0; \
    coq_makefile -f _CoqProject -o Makefile; \
    make;

FROM docker.io/library/ubuntu:jammy

RUN useradd -m codewarrior
COPY --from=builder /opt/coq /opt/coq
COPY --from=builder /opt/coq_codewars-2.0.0/src /opt/coq_codewars-2.0.0/src
COPY --from=builder /opt/coq_codewars-2.0.0/theories/Loader.vo /opt/coq_codewars-2.0.0/theories/Loader.vo
RUN set -ex; \
    mkdir -p /workspace; \
    chown -R codewarrior: /workspace;

USER codewarrior
ENV OPAM_SWITCH_NAME=__coq-platform.2022.04.0~8.15~2022.04
ENV OPAM_SWITCH_PREFIX=/opt/coq/$OPAM_SWITCH_NAME
ENV USER=codewarrior \
    HOME=/home/codewarrior \
    CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml \
    OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs/lib/toplevel \
    PATH=$OPAM_SWITCH_PREFIX/bin:$PATH

WORKDIR /workspace
