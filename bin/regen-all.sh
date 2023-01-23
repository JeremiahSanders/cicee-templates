#!/usr/bin/env bash

# Common initialization params
declare SCRIPT_LOCATION="$(dirname "${BASH_SOURCE[0]}")"

"${SCRIPT_LOCATION}/regen-classlib-package-csharp.sh"
"${SCRIPT_LOCATION}/regen-classlib-package-fsharp.sh"
"${SCRIPT_LOCATION}/regen-webapi-service-csharp.sh"
"${SCRIPT_LOCATION}/regen-webapi-service-fsharp.sh"
