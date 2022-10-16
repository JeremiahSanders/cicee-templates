#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function ci-clean() {
  rm -rf "${BUILD_ROOT}" &&
    dotnet clean "${PROJECT_ROOT}/src"
}

export -f ci-clean
