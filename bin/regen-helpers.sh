#!/usr/bin/env bash

function reinitialize_solution_target() {
  # Create temp holder
  if [[ ! -d "${SOLUTION_TARGET}-temp" ]]; then
    mkdir "${SOLUTION_TARGET}-temp"
  fi

  # Set template configuration aside
  if [[ -d "${SOLUTION_TARGET}/.template.config" ]]; then
    mv "${SOLUTION_TARGET}/.template.config" "${SOLUTION_TARGET}-temp/.template.config"
  fi

  # Remove current template
  rm -rf "${SOLUTION_TARGET}" &&
    mkdir "${SOLUTION_TARGET}" ||
    echo "Failed to delete and recreate ${SOLUTION_TARGET}"
}

function reinitialize_solution_ci() {
  dotnet cicee template init -f --project-root "${SOLUTION_TARGET}"
}

function restore_solution_template_config() {
  # Restore template configuration
  if [[ -d "${SOLUTION_TARGET}-temp/.template.config" ]]; then
    mv "${SOLUTION_TARGET}-temp/.template.config" "${SOLUTION_TARGET}/.template.config"
  fi

  # Remove temp holder
  rm -rf "${SOLUTION_TARGET}-temp"
}

export -f reinitialize_solution_target
export -f reinitialize_solution_ci
export -f restore_solution_template_config
