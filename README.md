# Coq

Container image for Coq used by CodeRunner.

## Usage

```bash
$ ./bin/run
```

You can specify the container engine through the variable `CONTAINER_ENGINE` (default: `docker`). For example, with Podman:

```bash
$ CONTAINER_ENGINE=podman ./bin/run
```

## Building

```bash
docker build -t ghcr.io/codewars/coq:latest .
```
