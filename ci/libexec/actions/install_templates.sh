#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function install_templates() {
  package_templates &&
    dotnet new install "${BUILD_PACKAGED_DIST}/nuget/Cicee.Templates.${PROJECT_VERSION_DIST}.nupkg"
}

export -f install_templates
