#!/usr/bin/env bash

# Common initialization params
declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"
declare REPOSITORY_ROOT="$(cd "${SCRIPT_LOCATION}/.." && pwd)"

if [[ -n "$(dotnet new --list | grep cicee)" ]]; then
  dotnet cicee lib exec --command uninstall_templates
fi

dotnet cicee lib exec --command install_templates
