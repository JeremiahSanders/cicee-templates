#!/usr/bin/env bash

# Fail or exit immediately if there is an error.
set -o errexit
# Fail if an unset variable is used.
set -o nounset
# Sets the exit code of a pipeline to that of the rightmost command to exit with a non-zero status,
# or zero if all commands of the pipeline exit successfully.
set -o pipefail

###
# Initialize a .NET project repository.
#   Creates a solution, source project, and optional unit and integration test projects.
#
#   Default project repository structure:
#     $PROJECT_ROOT/$SOLUTION_NAME.sln - Project solution
#     $PROJECT_ROOT/src/ - Source project
#     $PROJECT_ROOT/tests/integration/ - Integration test project
#     $PROJECT_ROOT/tests/unit/ - Unit test project
#   If $USE_DOMAIN=true:
#     $PROJECT_ROOT/src/$ASSEMBLY_NAME/ - Source project
#     $PROJECT_ROOT/src/$ASSEMBLY_NAME.Domain/ - Domain project
###

#-
# Required parameters
#-
# Solution name. E.g., TaskFulfillmentProcessor.
declare -r SOLUTION_NAME="${SOLUTION_NAME-}"
# Source project 'dotnet' template. E.g., classlib, webapi.
declare -r SOURCE_TEMPLATE="${SOURCE_TEMPLATE-}"
#-
# Recommended parameters
#-
# Repository root directory. Default: present working directory.
declare -r PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
# Source project .NET assembly name. E.g., OrganizationName.ProjectName, TaskFullfillmentProcessor. Default: $SOLUTION_NAME.
declare -r ASSEMBLY_NAME="${ASSEMBLY_NAME:-${SOLUTION_NAME}}"
#-
# Optional parameters
#-
# Language used in project repository. Default: C#.
declare -r PROJECT_LANGUAGE="${PROJECT_LANGUAGE:-C#}"
# Does the project repository maintain a domain library .NET project, as a dependency of the project's root .NET project? Default: false.
declare -r USE_DOMAIN="${USE_DOMAIN:-false}"
# Does the project repository use unit tests? Default: true.
declare -r USE_UNIT_TESTS="${USE_UNIT_TESTS:-true}"
# Does the project repository use integration tests? Default: false.
declare -r USE_INTEGRATION_TESTS="${USE_INTEGRATION_TESTS:-false}"
# Source project .NET framework. E.g., netcoreapp3.1, netstandard2.1, net6.0.
declare -r SOURCE_FRAMEWORK="${SOURCE_FRAMEWORK:-${PROJECT_FRAMEWORK:-}}"
#-
# Extended, optional parameters
#-
# Assembly name overrides
declare -r DOMAIN_TEMPLATE="${DOMAIN_TEMPLATE:-classlib}"
declare -r SOURCE_ASSEMBLY_NAME="${SOURCE_ASSEMBLY_NAME:-${ASSEMBLY_NAME}}"
declare -r DOMAIN_ASSEMBLY_NAME="${DOMAIN_ASSEMBLY_NAME:-${SOURCE_ASSEMBLY_NAME}.Domain}"
declare -r UNIT_TEST_ASSEMBLY_NAME="${UNIT_TEST_ASSEMBLY_NAME:-${SOURCE_ASSEMBLY_NAME}.Tests.Unit}"
declare -r INTEGRATION_TEST_ASSEMBLY_NAME="${INTEGRATION_TEST_ASSEMBLY_NAME:-${SOURCE_ASSEMBLY_NAME}.Tests.Integration}"
# Use PROJECT_FRAMEWORK if you want to set all projects (source, unit tests, integration tests) to the same framework.
declare -r PROJECT_FRAMEWORK="${PROJECT_FRAMEWORK:-}"
# Domain project framework.
declare -r DOMAIN_FRAMEWORK="${DOMAIN_FRAMEWORK:-${PROJECT_FRAMEWORK:-}}"
# Integration test project framework.
declare -r INTEGRATION_TEST_FRAMEWORK="${INTEGRATION_TEST_FRAMEWORK:-${PROJECT_FRAMEWORK:-}}"
# Unit test project framework.
declare -r UNIT_TEST_FRAMEWORK="${UNIT_TEST_FRAMEWORK:-${PROJECT_FRAMEWORK:-}}"
# Source directory name.
declare -r SOURCE_DIRECTORY_NAME="${SOURCE_DIRECTORY_NAME:-src}"
# Tests directory name. Default parent directory of unit and integration test projects.
declare -r PROJECT_TESTS_DIRECTORY_NAME="${PROJECT_TESTS_DIRECTORY_NAME:-tests}"
# Source project directory.
if [[ $USE_DOMAIN = true ]]; then
    declare -r SOURCE_DIRECTORY="${SOURCE_DIRECTORY:-${PROJECT_ROOT}/${SOURCE_DIRECTORY_NAME}/${SOURCE_ASSEMBLY_NAME}}"
else
    declare -r SOURCE_DIRECTORY="${SOURCE_DIRECTORY:-${PROJECT_ROOT}/${SOURCE_DIRECTORY_NAME}}"
fi
# Domain project directory.
declare -r DOMAIN_DIRECTORY="${DOMAIN_DIRECTORY:-${PROJECT_ROOT}/${SOURCE_DIRECTORY_NAME}/${DOMAIN_ASSEMBLY_NAME}}"
# Unit test project directory.
declare -r UNIT_TEST_DIRECTORY="${UNIT_TEST_DIRECTORY:-${PROJECT_ROOT}/${PROJECT_TESTS_DIRECTORY_NAME}/unit}"
# Integration test project directory.
declare -r INTEGRATION_TEST_DIRECTORY="${INTEGRATION_TEST_DIRECTORY:-${PROJECT_ROOT}/${PROJECT_TESTS_DIRECTORY_NAME}/integration}"

#-
# Workflow helpers
#-
declare PLANNED_EXIT_CODE=0

# Require that we're still planning to return exit code 0. If not, go ahead and exit with the failure.
function require_success_before_continuing() {
    if [[ ${PLANNED_EXIT_CODE} != 0 ]]; then
        # Use of return, rather than exit, works here to exit early because return provides the exit of the function, which pipefail then uses to exit in the composed execution.
        return $PLANNED_EXIT_CODE
    fi
}

# Text decoration values
declare normal=$(tput sgr0)
declare blue=$(tput setaf 4)
declare cyan=$(tput setaf 6)
declare green=$(tput setaf 2)
declare grey=$(tput setaf 7)
declare magenta=$(tput setaf 5)
declare red=$(tput setaf 1)
declare yellow=$(tput setaf 3)

#-
# Parameter validation
#-

function require_env_value() {
    if [[ -z "${!1}" ]]; then
        printf "%s: ${red}Missing; Required${normal}\n" "${1}" && PLANNED_EXIT_CODE=1
    else
        printf "%s: ${green}%s${normal}\n" "${1}" "${!1}"
    fi
}

function recommended_env_value() {
    if [[ -n "${!1}" ]]; then
        printf "%s: ${yellow}%s${normal}\n" "${1}" "${!1}"
    else
        printf "%s: ${magenta}Missing; Recommended${normal}\n" "${1}"
    fi
}

function optional_env_value() {
    if [[ -n "${!1}" ]]; then
        printf "%s: ${blue}%s${normal}\n" "${1}" "${!1}"
    else
        printf '%s:\n' "${1}"
    fi
}

# Require and display parameters
function require_parameters() {
    printf "Initialization plan:\n\n" &&
        require_env_value SOLUTION_NAME &&
        recommended_env_value ASSEMBLY_NAME &&
        recommended_env_value PROJECT_ROOT &&
        optional_env_value PROJECT_TESTS_DIRECTORY_NAME &&
        optional_env_value PROJECT_FRAMEWORK &&
        optional_env_value PROJECT_LANGUAGE &&
        printf "\n" &&
        optional_env_value SOURCE_DIRECTORY &&
        optional_env_value SOURCE_ASSEMBLY_NAME &&
        require_env_value SOURCE_TEMPLATE &&
        optional_env_value SOURCE_FRAMEWORK &&
        printf "\n" &&
        optional_env_value USE_DOMAIN &&
        optional_env_value DOMAIN_DIRECTORY &&
        optional_env_value DOMAIN_ASSEMBLY_NAME &&
        require_env_value DOMAIN_TEMPLATE &&
        optional_env_value DOMAIN_FRAMEWORK &&
        printf "\n" &&
        recommended_env_value USE_UNIT_TESTS &&
        optional_env_value UNIT_TEST_DIRECTORY &&
        optional_env_value UNIT_TEST_ASSEMBLY_NAME &&
        optional_env_value UNIT_TEST_FRAMEWORK &&
        printf "\n" &&
        recommended_env_value USE_INTEGRATION_TESTS &&
        optional_env_value INTEGRATION_TEST_DIRECTORY &&
        optional_env_value INTEGRATION_TEST_ASSEMBLY_NAME &&
        optional_env_value INTEGRATION_TEST_FRAMEWORK
}

#-
# User Confirmation
#-

function require_user_confirm() {
    if [[ "${FORCE}" = true ]]; then
      printf "\n\nInitialization forced.\n\n"
      export PLANNED_EXIT_CODE=0
      return
    fi
    printf "\n\n"
    # -n Character count to read; -p Prompt
    read -n 1 -p "Initialize (${green}Y${normal} or ${green}y${normal} begins initialization)?  ${green}" SHOULD_CONTINUE
    printf "${normal}\n"
    # The ,, inside parameter expansion converts to lowercase.
    if [[ "${SHOULD_CONTINUE,,}" != "y" ]]; then
        printf "\n\nInitialization canceled.\n\n"
        export PLANNED_EXIT_CODE=2
    fi
}

#-
# Initialization
#-

function create_globaljson() {
    local possibleGlobalJsonPath="${PROJECT_ROOT}/global.json"
    if [[ -f "${possibleGlobalJsonPath}" ]]; then
        printf "\n${yellow}Skipping${normal} global.json creation.\n${green}%s${normal} already exists.\n\n" "${possibleGlobalJsonPath}"
    else
        printf "\nCreating global.json at '${green}%s${normal}'\n\n" "${PROJECT_ROOT}" &&
            dotnet new globaljson --roll-forward latestFeature --output "${PROJECT_ROOT}" &&
            printf "Solution created.\n"
    fi
}

function create_solution() {
    local possibleSolutionPath="${PROJECT_ROOT}/${SOLUTION_NAME}.sln"
    if [[ -f "${possibleSolutionPath}" ]]; then
        printf "\n${yellow}Skipping${normal} solution creation.\n${green}%s${normal} already exists.\n\n" "${possibleSolutionPath}"
    else
        printf "\nCreating solution '${green}%s${normal}' at '${green}%s${normal}'\n\n" "${SOLUTION_NAME}" "${PROJECT_ROOT}" &&
            dotnet new sln --name "${SOLUTION_NAME}" --output "${PROJECT_ROOT}" &&
            printf "Solution created.\n"
    fi
}

function create_domain_project() {
    if [[ -d "${DOMAIN_DIRECTORY}" ]]; then
        printf "\n${yellow}Skipping${normal} domain project creation.\n${green}%s${normal} already exists.\n\n" "${DOMAIN_DIRECTORY}"
    else
        if [[ -n "${DOMAIN_FRAMEWORK}" ]]; then
            local -r frameworkArguments="--framework ${DOMAIN_FRAMEWORK}"
        else
            local -r frameworkArguments=""
        fi
        printf "\nCreating domain project '${green}%s${normal}' at '${green}%s${normal}'\n\n" "${DOMAIN_ASSEMBLY_NAME}" "${DOMAIN_DIRECTORY}" &&
            dotnet new "${DOMAIN_TEMPLATE}" --output "${DOMAIN_DIRECTORY}" --name "${DOMAIN_ASSEMBLY_NAME}" --language "${PROJECT_LANGUAGE}" $frameworkArguments &&
            dotnet sln "${PROJECT_ROOT}" add "${DOMAIN_DIRECTORY}" &&
            printf "\nCreated domain project.\n"
    fi
}

function create_source_project() {
    if [[ -d "${SOURCE_DIRECTORY}" ]]; then
        printf "\n${yellow}Skipping${normal} source project creation.\n${green}%s${normal} already exists.\n\n" "${SOURCE_DIRECTORY}"
    else
        if [[ -n "${SOURCE_FRAMEWORK}" ]]; then
            local -r frameworkArguments="--framework ${SOURCE_FRAMEWORK}"
        else
            local -r frameworkArguments=""
        fi
        printf "\nCreating source project '${green}%s${normal}' at '${green}%s${normal}'\n\n" "${SOURCE_ASSEMBLY_NAME}" "${SOURCE_DIRECTORY}" &&
            dotnet new "${SOURCE_TEMPLATE}" --output "${SOURCE_DIRECTORY}" --name "${SOURCE_ASSEMBLY_NAME}" --language "${PROJECT_LANGUAGE}" $frameworkArguments &&
            dotnet sln "${PROJECT_ROOT}" add "${SOURCE_DIRECTORY}" &&
            printf "\nCreated source project.\n"

        if [[ $USE_DOMAIN = true ]]; then
            dotnet add "${SOURCE_DIRECTORY}" reference "${DOMAIN_DIRECTORY}" &&
                printf "\nReferenced domain project in source project.\n"
        fi
    fi
}

function create_unit_test_project() {
    if [[ -d "${UNIT_TEST_DIRECTORY}" ]]; then
        printf "\n${yellow}Skipping${normal} unit test project creation.\n${green}%s${normal} already exists.\n\n" "${UNIT_TEST_DIRECTORY}"
    else
        if [[ -n "${UNIT_TEST_FRAMEWORK}" ]]; then
            local -r frameworkArguments="--framework ${UNIT_TEST_FRAMEWORK}"
        else
            local -r frameworkArguments=""
        fi
        printf "\nCreating unit test project '${green}%s${normal}' at '${green}%s${normal}'\n\n" "${UNIT_TEST_ASSEMBLY_NAME}" "${UNIT_TEST_DIRECTORY}" &&
            dotnet new xunit --output "${UNIT_TEST_DIRECTORY}" --name "${UNIT_TEST_ASSEMBLY_NAME}" --language "${PROJECT_LANGUAGE}" $frameworkArguments &&
            dotnet sln "${PROJECT_ROOT}" add "${UNIT_TEST_DIRECTORY}" &&
            dotnet add "${UNIT_TEST_DIRECTORY}" reference "${SOURCE_DIRECTORY}" &&
            printf "\nCreated unit test project.\n"
    fi
}

function create_integration_test_project() {
    function create_xunit_configuration() {
        # Shadow copying causes the tests to execute in a different directory than the output directory. For integration tests to work properly, shadow copying must be disabled.
        # See: https://docs.microsoft.com/en-us/aspnet/core/test/integration-tests?view=aspnetcore-6.0#disable-shadow-copying
        # Using assembly-named configuration file to function whether tests are executed from isolated build directory, or in a combined build directory.
        # See: https://xunit.net/docs/configuration-files
        local -r XUNIT_CONFIG_CONTENT="{
  \"\$schema\": \"https://xunit.net/schema/current/xunit.runner.schema.json\",
  \"shadowCopy\": false
}"
        local -r XUNIT_CONFIG_PATH="${INTEGRATION_TEST_DIRECTORY}/${ASSEMBLY_NAME}.xunit.runner.json"
        # Write the content to the config path
        echo "${XUNIT_CONFIG_CONTENT}" >"${XUNIT_CONFIG_PATH}"
    }

    if [[ -d "${INTEGRATION_TEST_DIRECTORY}" ]]; then
        printf "\n${yellow}Skipping${normal} integration test project creation.\n${green}%s${normal} already exists.\n\n" "${INTEGRATION_TEST_DIRECTORY}"
    else
        if [[ -n "${INTEGRATION_TEST_FRAMEWORK}" ]]; then
            local -r frameworkArguments="--framework ${INTEGRATION_TEST_FRAMEWORK}"
        else
            local -r frameworkArguments=""
        fi
        printf "\nCreating integration test project '${green}%s${normal}' at '${green}%s${normal}'\n\n" "${INTEGRATION_TEST_ASSEMBLY_NAME}" "${INTEGRATION_TEST_DIRECTORY}" &&
            dotnet new xunit --output "${INTEGRATION_TEST_DIRECTORY}" --name "${INTEGRATION_TEST_ASSEMBLY_NAME}" --language "${PROJECT_LANGUAGE}" $frameworkArguments &&
            dotnet sln "${PROJECT_ROOT}" add "${INTEGRATION_TEST_DIRECTORY}" &&
            dotnet add "${INTEGRATION_TEST_DIRECTORY}" reference "${SOURCE_DIRECTORY}" &&
            dotnet add "${INTEGRATION_TEST_DIRECTORY}" reference "${UNIT_TEST_DIRECTORY}" &&
            create_xunit_configuration &&
            printf "\nCreated integration test project.\n"
    fi
}

function initialize_project() {
    # Skip creating global.json for templates
    # create_globaljson
    create_solution
    if [[ $USE_DOMAIN = true ]]; then
        create_domain_project
    fi
    create_source_project
    if [[ $USE_UNIT_TESTS = true ]]; then
        create_unit_test_project
        if [[ $USE_INTEGRATION_TESTS = true ]]; then
            create_integration_test_project
        fi
    fi
}

#-
# Execution
#-

printf "\n\nInitializing a .NET solution at '${green}%s${normal}'...\n\n" "${PROJECT_ROOT}" &&
    require_parameters &&
    require_success_before_continuing &&
    require_user_confirm &&
    require_success_before_continuing &&
    initialize_project &&
    require_success_before_continuing &&
    printf "\n\n.NET solution initialization completed.\n"
