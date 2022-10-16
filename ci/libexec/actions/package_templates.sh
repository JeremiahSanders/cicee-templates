#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function package_templates() {
  dotnet pack "${PROJECT_ROOT}/src" \
    --configuration Release \
    --output "${BUILD_PACKAGED_DIST}/nuget/" \
    -p:PackageVersion="${PROJECT_VERSION_DIST}" \
    -p:Version="${PROJECT_VERSION_DIST}"
}

export -f package_templates
