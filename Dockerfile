FROM alpine:3.16

ENV OPAMROOT=/opt/coq \
    OPAMYES=1 \
    OCAML_VERSION=default
ENV OPAM_SWITCH_PREFIX=/opt/coq/default
ENV CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml \
    OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs/lib/toplevel \
    PATH=$OPAM_SWITCH_PREFIX/bin:$PATH

RUN set -ex; \
    mkdir -p /opt/coq; \
    # Work around https://github.com/ocaml/opam/issues/5186 by doing
    # `apk update` then cleaning up the cache in the same layer.
    apk update; \
    apk add \
        ocaml \
    ; \
    apk add --virtual .build-deps \
        bash \
        build-base \
        bubblewrap \
        ca-certificates \
        curl \
        git \
        m4 \
        ocaml-ocamldoc \
        ocaml-compiler-libs \
        opam \
        tar \
    ; \
    opam init -y --disable-sandboxing; \
    opam repo add coq-released http://coq.inria.fr/opam/released; \
    opam install -j 4 \
    # Let opam install system packages
        --confirm-level=unsafe-yes \
    # Use the same versions as Coq Platform so users can easily get the same versions.
    # https://github.com/coq/platform/blob/main/package_picks/package-pick-8.15%7E2022.04.sh
        coq.8.15.2 \
        coq-equations.1.3+8.15 \
        coq-mathcomp-ssreflect.1.14.0 \
    ; \
    cd /opt; \
    mkdir /opt/coq_codewars; \
    curl -sSL https://github.com/codewars/coq_codewars/archive/refs/tags/v2.0.0.tar.gz | tar xz -C /opt/coq_codewars --strip-components=1; \
    cd coq_codewars; \
    coq_makefile -f _CoqProject -o Makefile; \
    make; \
    opam clean --repo-cache; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/*;

RUN adduser -D codewarrior
RUN set -ex; \
    mkdir -p /workspace; \
    chown -R codewarrior: /workspace;

USER codewarrior
WORKDIR /workspace
