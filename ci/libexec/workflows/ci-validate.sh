#!/usr/bin/env bash
# shellcheck disable=SC2155

###
# Validate the project's source, e.g. run tests, linting.
#
#   This script expects a CICEE CI library environment (which is provided when using 'cicee lib exec').
#   For CI library environment details, see: https://github.com/JeremiahSanders/cicee/blob/main/docs/use/ci-library.md
#
# How to use:
#   Modify the "ci-validate" function, below, to execute the steps required to produce the project's artifacts.
###

set -o errexit  # Fail or exit immediately if there is an error.
set -o nounset  # Fail if an unset variable is used.
set -o pipefail # Fail pipelines if any command errors, not just the last one.

# Local "action"/"build step" function to generate example/test output.
function __generateTestOutput() {
  local GENERATED_OUTPUT="${BUILD_ROOT}/generated"

  if [[ ! -d "${BUILD_ROOT}" ]]; then
    mkdir "${BUILD_ROOT}"
  fi

  if [[ ! -d "${GENERATED_OUTPUT}" ]]; then
    mkdir "${GENERATED_OUTPUT}"
  fi
  function __createGlobalJson() {
    dotnet new globaljson --sdk-version "8.0.100" --roll-forward "latestMinor"
  }

  function __init_classlib_package_csharp() {
    local CLASSLIB_PACKAGE_CSHARP="${GENERATED_OUTPUT}/classlib-package-csharp"
    mkdir "${CLASSLIB_PACKAGE_CSHARP}" &&
      cd "${CLASSLIB_PACKAGE_CSHARP}" &&
      __createGlobalJson &&
      dotnet new cicee-classlib-package --language C# --name "MyCoolLibrary" --allow-scripts "Yes"
  }
  function __init_classlib_package_fsharp() {
    local CLASSLIB_PACKAGE_FSHARP="${GENERATED_OUTPUT}/classlib-package-fsharp"
    mkdir "${CLASSLIB_PACKAGE_FSHARP}" &&
      cd "${CLASSLIB_PACKAGE_FSHARP}" &&
      __createGlobalJson &&
      dotnet new cicee-classlib-package --language F# --name "MyCoolLibrary" --allow-scripts "Yes"
  }

  function __init_webapi_service_csharp() {
    local WEBAPI_SERVICE_CSHARP="${GENERATED_OUTPUT}/webapi-service-csharp"
    mkdir "${WEBAPI_SERVICE_CSHARP}" &&
      cd "${WEBAPI_SERVICE_CSHARP}" &&
      __createGlobalJson &&
      dotnet new cicee-webapi-service --language C# --name "MyAwesomeWebService" --allow-scripts "Yes"
  }
  function __init_webapi_service_fsharp() {
    local WEBAPI_SERVICE_FSHARP="${GENERATED_OUTPUT}/webapi-service-fsharp"
    mkdir "${WEBAPI_SERVICE_FSHARP}" &&
      cd "${WEBAPI_SERVICE_FSHARP}" &&
      __createGlobalJson &&
      dotnet new cicee-webapi-service --language F# --name "MyAwesomeWebService" --allow-scripts "Yes"
  }

  __init_classlib_package_csharp &&
    __init_classlib_package_fsharp &&
    __init_webapi_service_csharp &&
    __init_webapi_service_fsharp
}

# Local "action"/"build step" function to build project outputs.
function __generateExampleProjects() {
  dotnet build "${PROJECT_ROOT}/src" --no-incremental &&
    install_templates &&
    __generateTestOutput
}

# Local function to verify that all templates' configuration files contain the GUIDs present in templates (so 'dotnet new' initializes as expected).
function __requireTemplateGuidsConfigured() {
  require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-csharp/ClassLibPackage.sln" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-csharp/src/library/ClassLibPackage.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-csharp/tests/unit/ClassLibPackage.Tests.Unit.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/ClassLibPackage.sln" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/src/library/ClassLibPackage.fsproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/classlib-package-fsharp/tests/unit/ClassLibPackage.Tests.Unit.fsproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-csharp/ApiService.sln" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-csharp/src/domain/ApiService.Domain.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-csharp/src/webapi/ApiService.WebApi.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-csharp/tests/unit/ApiService.Tests.Unit.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-csharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-csharp/tests/integration/ApiService.Tests.Integration.csproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/ApiService.sln" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/src/domain/ApiService.Domain.fsproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/src/webapi/ApiService.WebApi.fsproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/tests/unit/ApiService.Tests.Unit.fsproj" &&
    require_guids_configured "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/.template.config/template.json" "${PROJECT_ROOT}/src/templates/webapi-service-fsharp/tests/integration/ApiService.Tests.Integration.fsproj"
}

function __remove_build() {
  rm -rf "${BUILD_ROOT}"
}

function __reset_environment() {
  uninstall_templates && ci-clean || ci-clean
}

function ci-validate() {
  printf "Beginning validation...\n\n" &&
    __remove_build &&
    __reset_environment &&
    __requireTemplateGuidsConfigured &&
    __generateExampleProjects &&
    uninstall_templates &&
    printf "Validation complete!\n\n"
}

export -f ci-validate
