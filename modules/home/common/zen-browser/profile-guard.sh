# Read-only preflight: adopting an existing unmanaged profile requires an
# explicit backup/reconciliation by the user, not Home Manager's file backup.
config_dir=$1
profile_dir=$2

managed_link() {
  if [ -L "$1" ]; then
    case "$(readlink "$1")" in
      /nix/store/*) return 0 ;;
    esac
  fi
  return 1
}

if { [ -e "$config_dir/profiles.ini" ] || [ -L "$config_dir/profiles.ini" ]; } &&
  ! managed_link "$config_dir/profiles.ini"; then
  echo "Zen: refusing to replace unmanaged $config_dir/profiles.ini. Back up and reconcile the existing profile before activation." >&2
  exit 1
fi

if [ -d "$profile_dir" ] && [ -n "$(ls -A "$profile_dir")" ] &&
  ! managed_link "$profile_dir/user.js"; then
  echo "Zen: refusing to adopt unmanaged $profile_dir. Back up and reconcile the existing profile before activation." >&2
  exit 1
fi
