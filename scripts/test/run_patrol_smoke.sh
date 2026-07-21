#!/usr/bin/env bash
set -euo pipefail

if ! command -v patrol >/dev/null 2>&1; then
  echo "Patrol CLI is not installed. Installing patrol_cli globally..."
  dart pub global activate patrol_cli
fi

export PATROL_ANALYTICS_ENABLED="${PATROL_ANALYTICS_ENABLED:-false}"

patrol test --target integration_test/app_smoke_test.dart "$@"
