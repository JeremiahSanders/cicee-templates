#!/usr/bin/env bash

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

function uninstall_templates() {
  if [[ -n "$(dotnet new uninstall | grep "Cicee.Templates")" ]]; then
    dotnet new uninstall "Cicee.Templates"
  fi
}

export -f uninstall_templates
