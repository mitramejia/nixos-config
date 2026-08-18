#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  device-preflight.sh --platform <android|ios> --device <serial-or-simulator-udid> \
    --app-id <package-or-bundle-id> [--metro-url <url>] [--artifact <path>]

Prints read-only key=value provenance for one installed Android target or iOS
simulator Comun Debug app.
EOF
}

die() {
  printf 'error=%s\n' "$1" >&2
  exit 1
}

emit() {
  local value=${2//$'\n'/ }
  printf '%s=%s\n' "$1" "$value"
}

resolve_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return
  fi

  local candidate
  for candidate in \
    "${ANDROID_HOME:-}/platform-tools/adb" \
    "${ANDROID_SDK_ROOT:-}/platform-tools/adb" \
    "${HOME:-}/Library/Android/sdk/platform-tools/adb"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  die "adb not found"
}

platform=''
device=''
app_id=''
metro_url='http://127.0.0.1:8081'
artifact=''

while (($#)); do
  case "$1" in
    --platform) platform=${2:-}; shift 2 ;;
    --device) device=${2:-}; shift 2 ;;
    --app-id) app_id=${2:-}; shift 2 ;;
    --metro-url) metro_url=${2:-}; shift 2 ;;
    --artifact) artifact=${2:-}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ "$platform" == android || "$platform" == ios ]] || die "--platform must be android or ios"
[[ -n "$device" ]] || die "--device is required"
[[ -n "$app_id" ]] || die "--app-id is required"
[[ -z "$artifact" || -f "$artifact" ]] || die "artifact not found: $artifact"

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "run inside a Git checkout"
revision=$(git -C "$repo_root" rev-parse HEAD)
diff_hash=$(
  { git -C "$repo_root" diff --binary; git -C "$repo_root" diff --cached --binary; } |
    shasum -a 256 | awk '{print $1}'
)

emit git_revision "$revision"
emit git_diff_sha256 "$diff_hash"
emit platform "$platform"
emit device "$device"
emit app_id "$app_id"
emit metro_url "$metro_url"

metro_status='unreachable'
if curl -fsS --max-time 2 "${metro_url%/}/status" 2>/dev/null | grep -q 'packager-status:running'; then
  metro_status='running'
fi
emit metro_status "$metro_status"

if [[ -n "$artifact" ]]; then
  emit artifact_path "$artifact"
  emit artifact_sha256 "$(shasum -a 256 "$artifact" | awk '{print $1}')"
else
  emit artifact_path reused-installed-binary
  emit artifact_sha256 unavailable
fi

if [[ "$platform" == android ]]; then
  adb_bin=$(resolve_adb)
  state=$($adb_bin -s "$device" get-state 2>/dev/null || true)
  [[ "$state" == device ]] || die "Android target is not ready: $device"

  package_dump=$($adb_bin -s "$device" shell dumpsys package "$app_id" 2>/dev/null || true)
  package_path=$($adb_bin -s "$device" shell pm path "$app_id" 2>/dev/null | tr -d '\r')
  reverse_state=$($adb_bin -s "$device" reverse --list 2>/dev/null | tr '\n' ';' || true)

  emit device_model "$($adb_bin -s "$device" shell getprop ro.product.model | tr -d '\r')"
  emit os_version "$($adb_bin -s "$device" shell getprop ro.build.version.release | tr -d '\r')"
  emit os_api "$($adb_bin -s "$device" shell getprop ro.build.version.sdk | tr -d '\r')"
  emit app_installed "$([[ -n "$package_path" ]] && printf yes || printf no)"
  emit app_version "$(sed -n 's/.*versionName=\([^ ]*\).*/\1/p' <<<"$package_dump" | head -1)"
  emit app_build "$(sed -n 's/.*versionCode=\([^ ]*\).*/\1/p' <<<"$package_dump" | head -1)"
  emit app_last_update "$(sed -n 's/.*lastUpdateTime=//p' <<<"$package_dump" | head -1 | xargs)"
  emit adb_reverse "${reverse_state:-none}"
else
  command -v xcrun >/dev/null 2>&1 || die "xcrun not found"
  device_line=$(xcrun simctl list devices available | grep -F "$device" | head -1 || true)
  [[ -n "$device_line" ]] || die "iOS simulator not found: $device"

  app_path=$(xcrun simctl get_app_container "$device" "$app_id" app 2>/dev/null || true)
  os_version=$(xcrun simctl getenv "$device" SIMULATOR_RUNTIME_VERSION 2>/dev/null || true)
  app_version=''
  app_build=''
  if [[ -n "$app_path" && -f "$app_path/Info.plist" ]]; then
    app_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_path/Info.plist" 2>/dev/null || true)
    app_build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app_path/Info.plist" 2>/dev/null || true)
  fi

  emit device_description "$device_line"
  emit os_version "${os_version:-unavailable}"
  emit app_installed "$([[ -n "$app_path" ]] && printf yes || printf no)"
  emit app_version "${app_version:-unavailable}"
  emit app_build "${app_build:-unavailable}"
fi
