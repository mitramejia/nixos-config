{pkgs, ...}: let
  ollamaCodexCompat = pkgs.writeShellApplication {
    name = "ollama";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
    ];
    text = ''
            set -euo pipefail

            real_ollama=${pkgs.ollama-rocm}/bin/ollama

            if [ "$#" -ge 2 ] && [ "$1" = "launch" ] && [ "$2" = "codex" ]; then
              shift 2

              model_args=()
              extra_args=()
              config_only=false

              while [ "$#" -gt 0 ]; do
                case "$1" in
                  --model)
                    if [ "$#" -lt 2 ]; then
                      echo "ollama launch codex: --model requires an argument" >&2
                      exit 2
                    fi
                    model_args=(--model "$2")
                    shift 2
                    ;;
                  --model=*)
                    model_args=(--model "''${1#--model=}")
                    shift
                    ;;
                  --config)
                    config_only=true
                    shift
                    ;;
                  -y|--yes|--restore)
                    shift
                    ;;
                  --)
                    shift
                    extra_args+=("$@")
                    break
                    ;;
                  *)
                    extra_args+=("$1")
                    shift
                    ;;
                esac
              done

              codex_home="''${CODEX_HOME:-$HOME/.codex}"
              config_file="$codex_home/config.toml"
              profile_file="$codex_home/ollama-launch.config.toml"

              mkdir -p "$codex_home"

              if [ -f "$config_file" ]; then
                cleaned_config=$(mktemp)
                awk '
                  /^\[profiles\.ollama-launch\]$/ { skip = 1; next }
                  skip && /^\[/ { skip = 0 }
                  !skip { print }
                ' "$config_file" > "$cleaned_config"
                cat "$cleaned_config" > "$config_file"
                rm -f "$cleaned_config"
              fi

              cat > "$profile_file" <<'PROFILE'
      model_provider = "ollama-launch"
      forced_login_method = "api"

      [model_providers.ollama-launch]
      name = "Ollama"
      base_url = "http://127.0.0.1:11434/v1/"
      wire_api = "responses"
      PROFILE

              if [ "$config_only" = true ]; then
                exit 0
              fi

              exec ${pkgs.codex}/bin/codex --profile ollama-launch "''${model_args[@]}" "''${extra_args[@]}"
            fi

            exec "$real_ollama" "$@"
    '';
  };
in {
  # Ollama 0.24.0 still writes Codex's legacy [profiles.ollama-launch] table before
  # launching Codex. Codex 0.134+ rejects that format, so this wrapper preserves normal
  # Ollama behavior while translating `ollama launch codex` to the v2 profile file.
  environment.systemPackages = [
    ollamaCodexCompat
  ];
}
