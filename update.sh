#!/bin/bash

set -euo pipefail

bazel build //docker:docker.par

cp -f bazel-bin/docker/docker.par tools/docker.par
