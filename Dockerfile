FROM alpine:3.11 AS builder

RUN apk add --no-cache \
      bash \
      bubblewrap \
      build-base \
      ca-certificates \
      coreutils \
      curl \
      git \
      m4 \
      ncurses-dev \
      opam \
      ocaml \
      ocaml-compiler-libs \
      patch \
      rsync \
      tar \
      xz \
    ;

# Disable sandboxing
RUN set -ex; \
    echo 'wrap-build-commands: []' > ~/.opamrc; \
    echo 'wrap-install-commands: []' >> ~/.opamrc; \
    echo 'wrap-remove-commands: []' >> ~/.opamrc; \
    echo 'required-tools: []' >> ~/.opamrc;

ENV OPAMROOT=/opt/coq \
    OPAMYES=1 \
    OCAML_VERSION=default

RUN set -ex; \
    mkdir -p /opt/coq; \
    opam init --no-setup -j 4; \
    opam repo add coq-released http://coq.inria.fr/opam/released; \
    opam install -j 4 coq.8.12.0; \
    opam pin add coq 8.12.0; \
    opam install \
      -j 4 \
      coq-equations.1.2.3+8.12 \
      coq-mathcomp-ssreflect.1.11.0 \
    ;

ENV OPAM_SWITCH_PREFIX=/opt/coq/default
ENV CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml \
    OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs/lib/toplevel \
    PATH=$OPAM_SWITCH_PREFIX/bin:$PATH
RUN set -ex; \
    cd /opt; \
    git clone --depth 1 --branch v2.0.0 https://github.com/codewars/coq_codewars.git; \
    cd coq_codewars; \
    coq_makefile -f _CoqProject -o Makefile; \
    make;


FROM alpine:3.11

RUN adduser -D codewarrior
RUN apk add --no-cache \
      build-base \
      ncurses-dev \
      ocaml \
    ;
COPY --from=builder /opt/coq /opt/coq
COPY --from=builder /opt/coq_codewars/src /opt/coq_codewars/src
COPY --from=builder /opt/coq_codewars/theories/Loader.vo /opt/coq_codewars/theories/Loader.vo
RUN set -ex; \
    mkdir -p /workspace; \
    chown codewarrior:codewarrior /workspace;

USER codewarrior
ENV OPAM_SWITCH_PREFIX=/opt/coq/default
ENV USER=codewarrior \
    HOME=/home/codewarrior \
    CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml \
    OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs/lib/toplevel \
    PATH=$OPAM_SWITCH_PREFIX/bin:$PATH

WORKDIR /workspace
