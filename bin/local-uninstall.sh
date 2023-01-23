#!/usr/bin/env bash

# Common initialization params
declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"
declare REPOSITORY_ROOT="$(cd "${SCRIPT_LOCATION}/.." && pwd)"

dotnet cicee lib exec --command uninstall_templates
