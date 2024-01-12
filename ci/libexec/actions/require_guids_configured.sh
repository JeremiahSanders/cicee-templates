#!/usr/bin/env bash

function require_guids_configured() {
  configFilePath=$1
  sourceFilePath=$2

  echo "Verifying that all non-.NET GUIDs in ${sourceFilePath} are defined in ${configFilePath}."

  # Get all GUIDs from configFilePath
  configuredGuids=$(grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' $configFilePath)

  # Define a list of .NET GUIDs which need not be present in configuration (because they should be unchanged)
  predefinedGuids=(
    2150E333-8FDC-42A3-9474-1A3956D46DE8
    FAE04EC0-301F-11D3-BF4B-00C04F79EFBC
    F2A71F9B-5D33-465A-A702-920D77279786
  )

  # Check if every predefined GUID is present in configFilePath
  for guid in "${predefinedGuids[@]}"; do
    if grep -q "$guid" "$configFilePath"; then
      echo ".NET GUID $guid is present in $configFilePath . This may cause compilation errors."
      return 1
    fi
  done

  # Check if every GUID in sourceFilePath is present in configFilePath or predefinedGuids
  for guid in $(grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' $sourceFilePath); do
    if ! grep -q "$guid" "$configFilePath" && [[ ! " ${predefinedGuids[@]} " =~ " $guid " ]]; then
      echo "GUID $guid is not present in $configFilePath or predefinedGuids"
      return 1
    fi
  done

  echo "All GUIDs in $sourceFilePath are present in $configFilePath or predefinedGuids"
  return 0
}
