#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  android-contact-fixture.sh add --serial <emulator-serial> --label <no-space-label> --phone <number>
  android-contact-fixture.sh remove --serial <emulator-serial> --raw-id <id>
  android-contact-fixture.sh verify-absent --serial <emulator-serial> --label <no-space-label>

The helper operates only on an explicitly named Android emulator. `add` prints
raw_contact_id=<id>; save that ID and pass it to `remove` during cleanup.
EOF
}

die() {
  printf 'error=%s\n' "$1" >&2
  exit 1
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

query_raw_ids() {
  "$adb_bin" -s "$serial" shell content query \
    --uri content://com.android.contacts/raw_contacts \
    --projection _id 2>/dev/null |
    sed -n 's/.*_id=\([0-9][0-9]*\).*/\1/p' |
    sort -n -u
}

raw_id_exists() {
  query_raw_ids | grep -qx "$1"
}

label_exists() {
  "$adb_bin" -s "$serial" shell content query \
    --uri content://com.android.contacts/data \
    --projection data1 2>/dev/null |
    grep -Eq "(^|[ ,])data1=${1}([, ]|$)"
}

command_name=${1:-}
if [[ "$command_name" == -h || "$command_name" == --help || -z "$command_name" ]]; then
  usage
  [[ -n "$command_name" ]] && exit 0 || exit 1
fi
shift

serial=''
label=''
phone=''
raw_id=''

while (($#)); do
  case "$1" in
    --serial) serial=${2:-}; shift 2 ;;
    --label) label=${2:-}; shift 2 ;;
    --phone) phone=${2:-}; shift 2 ;;
    --raw-id) raw_id=${2:-}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ "$command_name" == add || "$command_name" == remove || "$command_name" == verify-absent ]] || die "unknown command: $command_name"
[[ "$serial" == emulator-* ]] || die "--serial must name an explicit Android emulator"
[[ -z "$label" || "$label" =~ ^[A-Za-z0-9_-]+$ ]] || die "--label must contain only letters, numbers, underscore, or hyphen"
[[ -z "$phone" || "$phone" =~ ^[+0-9-]+$ ]] || die "--phone must contain only digits, plus, or hyphen"
[[ -z "$raw_id" || "$raw_id" =~ ^[0-9]+$ ]] || die "--raw-id must be numeric"

adb_bin=$(resolve_adb)
state=$($adb_bin -s "$serial" get-state 2>/dev/null || true)
[[ "$state" == device ]] || die "emulator is not ready: $serial"

case "$command_name" in
  add)
    [[ -n "$label" ]] || die "--label is required for add"
    [[ -n "$phone" ]] || die "--phone is required for add"
    label_exists "$label" && die "label already exists: $label"

    temp_dir=$(mktemp -d)
    created_id=''
    cleanup_on_exit() {
      local status=$?
      if ((status != 0)) && [[ -n "$created_id" ]]; then
        "$adb_bin" -s "$serial" shell content delete \
          --uri content://com.android.contacts/raw_contacts \
          --where "_id=$created_id" >/dev/null 2>&1 || true
      fi
      rm -rf "$temp_dir"
      exit "$status"
    }
    trap cleanup_on_exit EXIT

    query_raw_ids >"$temp_dir/before"
    "$adb_bin" -s "$serial" shell content insert \
      --uri content://com.android.contacts/raw_contacts \
      --bind aggregation_mode:i:3 >/dev/null
    query_raw_ids >"$temp_dir/after"
    comm -13 "$temp_dir/before" "$temp_dir/after" >"$temp_dir/new"
    new_count=$(awk 'END { print NR }' "$temp_dir/new")
    ((new_count == 1)) || die "expected one new raw contact, found $new_count"
    created_id=$(sed -n '1p' "$temp_dir/new")

    "$adb_bin" -s "$serial" shell content insert \
      --uri content://com.android.contacts/data \
      --bind "raw_contact_id:i:$created_id" \
      --bind mimetype:s:vnd.android.cursor.item/name \
      --bind "data1:s:$label" >/dev/null
    "$adb_bin" -s "$serial" shell content insert \
      --uri content://com.android.contacts/data \
      --bind "raw_contact_id:i:$created_id" \
      --bind mimetype:s:vnd.android.cursor.item/phone_v2 \
      --bind "data1:s:$phone" \
      --bind data2:i:2 >/dev/null

    raw_id_exists "$created_id" || die "raw contact was not persisted: $created_id"
    label_exists "$label" || die "contact label was not persisted: $label"
    printf 'raw_contact_id=%s\n' "$created_id"
    ;;
  remove)
    [[ -n "$raw_id" ]] || die "--raw-id is required for remove"
    raw_id_exists "$raw_id" || die "raw contact does not exist: $raw_id"
    "$adb_bin" -s "$serial" shell content delete \
      --uri content://com.android.contacts/raw_contacts \
      --where "_id=$raw_id" >/dev/null
    raw_id_exists "$raw_id" && die "raw contact still exists after delete: $raw_id"
    printf 'removed_raw_contact_id=%s\n' "$raw_id"
    ;;
  verify-absent)
    [[ -n "$label" ]] || die "--label is required for verify-absent"
    label_exists "$label" && die "contact label still exists: $label"
    printf 'label_absent=%s\n' "$label"
    ;;
esac
