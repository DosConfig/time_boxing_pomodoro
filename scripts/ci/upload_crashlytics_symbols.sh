#!/usr/bin/env bash

set -uo pipefail

# Flutter projects using Swift Package Manager can place Firebase's Crashlytics
# helper under different DerivedData directories on developer machines and CI.
# Resolve the installed helper instead of assuming one DerivedData hash.
crashlytics_run=""

candidate_paths=()

if [[ -n "${PODS_ROOT:-}" ]]; then
  candidate_paths+=("${PODS_ROOT}/FirebaseCrashlytics/run")
fi

if [[ -n "${BUILD_DIR:-}" ]]; then
  candidate_paths+=(
    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
  )
fi

if [[ -n "${BUILD_ROOT:-}" ]]; then
  derived_data_path="$(
    printf '%s\n' "${BUILD_ROOT}" |
      sed -E 's|(.*DerivedData/[^/]+).*|\1|'
  )"
  candidate_paths+=(
    "${derived_data_path}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
  )
fi

for candidate in "${candidate_paths[@]}"; do
  if [[ -x "${candidate}" ]]; then
    crashlytics_run="${candidate}"
    break
  fi
done

if [[ -z "${crashlytics_run}" ]]; then
  derived_data_root="${HOME:?}/Library/Developer/Xcode/DerivedData"
  if [[ -d "${derived_data_root}" ]]; then
    discovered_path="$(
      find "${derived_data_root}" \
        -path '*/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run' \
        -type f \
        -print \
        -quit 2>/dev/null
    )"
    if [[ -n "${discovered_path}" && -x "${discovered_path}" ]]; then
      crashlytics_run="${discovered_path}"
    fi
  fi
fi

if [[ -z "${crashlytics_run}" ]]; then
  echo "warning: Firebase Crashlytics run helper was not found; skipping automatic dSYM upload."
  echo "warning: The archive remains releasable, and its dSYM can be uploaded after the build."
  exit 0
fi

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "warning: flutterfire CLI was not found; skipping automatic dSYM upload."
  exit 0
fi

echo "Using Crashlytics helper: ${crashlytics_run}"

flutterfire upload-crashlytics-symbols \
  --upload-symbols-script-path="${crashlytics_run}" \
  --platform=ios \
  --apple-project-path="${SRCROOT}" \
  --env-platform-name="${PLATFORM_NAME}" \
  --env-configuration="${CONFIGURATION}" \
  --env-project-dir="${PROJECT_DIR}" \
  --env-built-products-dir="${BUILT_PRODUCTS_DIR}" \
  --env-dwarf-dsym-folder-path="${DWARF_DSYM_FOLDER_PATH}" \
  --env-dwarf-dsym-file-name="${DWARF_DSYM_FILE_NAME}" \
  --env-infoplist-path="${INFOPLIST_PATH}" \
  --target=Runner
