# Coq

Container image for Coq used by CodeRunner.

## Usage

```bash
W=/workspace
# Create container
C=$(docker container create --rm -w $W ghcr.io/codewars/coq:latest sh -c "coqc Solution.v && coqc -I /opt/coq_codewars/src -Q /opt/coq_codewars/theories CW SolutionTest.v")

# Copy files from the current directory
# ./Solution.v
# ./SolutionTest.v
docker container cp ./. $C:$W

# Start
docker container start --attach $C
```

## Building

```bash
docker build -t ghcr.io/codewars/coq:latest .
```
