#!/usr/bin/env bash

# Common initialization params
declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"
declare REPOSITORY_ROOT="$(cd "${SCRIPT_LOCATION}/.." && pwd)"
declare TEMPLATES_ROOT="${REPOSITORY_ROOT}/src/templates"
declare NET_INIT_COMMAND="${SCRIPT_LOCATION}/net-init.sh"
declare REGEN_HELPERS_SCRIPT="${SCRIPT_LOCATION}/regen-helpers.sh"

declare SOLUTION_TARGET="${TEMPLATES_ROOT}/webapi-service-csharp"

# This is the custom regeneration process for this template.
function initialize_solution() {
  PROJECT_ROOT="${SOLUTION_TARGET}" \
    ASSEMBLY_NAME="ApiService" \
    DOMAIN_ASSEMBLY_NAME="ApiService.Domain" \
    DOMAIN_DIRECTORY="${SOLUTION_TARGET}/src/domain" \
    INTEGRATION_TEST_ASSEMBLY_NAME="ApiService.Tests.Integration" \
    SOLUTION_NAME="ApiService" \
    SOURCE_ASSEMBLY_NAME="ApiService.WebApi" \
    SOURCE_DIRECTORY="${SOLUTION_TARGET}/src/webapi" \
    SOURCE_TEMPLATE="webapi" \
    UNIT_TEST_ASSEMBLY_NAME="ApiService.Tests.Unit" \
    USE_DOMAIN=true \
    USE_INTEGRATION_TESTS=true \
    PROJECT_LANGUAGE="C#" \
    FORCE=true \
    PROJECT_FRAMEWORK="net8.0" \
    "${NET_INIT_COMMAND}" &&
    dotnet add "${SOLUTION_TARGET}/tests/integration" package "Microsoft.AspNetCore.Mvc.Testing"
}

# Common regeneration workflow. Source the helpers, execute the reinitialization, then initialize the solution, then reinitialize CI, finally restore the configuration.
source "${REGEN_HELPERS_SCRIPT}" &&
  reinitialize_solution_target &&
  initialize_solution &&
  reinitialize_solution_ci &&
  restore_solution_template_config
