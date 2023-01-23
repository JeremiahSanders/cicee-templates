#!/usr/bin/env bash

# Common initialization params
declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"
declare REPOSITORY_ROOT="$(cd "${SCRIPT_LOCATION}/.." && pwd)"
declare TEMPLATES_ROOT="${REPOSITORY_ROOT}/src/templates"
declare NET_INIT_COMMAND="${SCRIPT_LOCATION}/net-init.sh"
declare REGEN_HELPERS_SCRIPT="${SCRIPT_LOCATION}/regen-helpers.sh"

declare SOLUTION_TARGET="${TEMPLATES_ROOT}/classlib-package-csharp"

# This is the custom regeneration process for this template.
function initialize_solution() {
  PROJECT_ROOT="${SOLUTION_TARGET}" \
    ASSEMBLY_NAME="ClassLibPackage" \
    SOLUTION_NAME="ClassLibPackage" \
    SOURCE_ASSEMBLY_NAME="ClassLibPackage" \
    SOURCE_DIRECTORY="${SOLUTION_TARGET}/src/library" \
    SOURCE_TEMPLATE="classlib" \
    UNIT_TEST_ASSEMBLY_NAME="ClassLibPackage.Tests.Unit" \
    USE_DOMAIN=false \
    USE_INTEGRATION_TESTS=false \
    PROJECT_LANGUAGE="C#" \
    FORCE=true \
    PROJECT_FRAMEWORK="net6.0" \
    "${NET_INIT_COMMAND}"
}

# Common regeneration workflow. Source the helpers, execute the reinitialization, then initialize the solution, then reinitialize CI, finally restore the configuration.
source "${REGEN_HELPERS_SCRIPT}" &&
  reinitialize_solution_target &&
  initialize_solution &&
  reinitialize_solution_ci &&
  restore_solution_template_config
