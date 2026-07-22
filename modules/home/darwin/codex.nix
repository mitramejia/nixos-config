{
  config,
  lib,
  pkgs,
  ...
}: {
  home.sessionVariables.ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";

  # Correct the pre-unification Android SDK location without replacing the
  # user-owned, editable Codex configuration.
  home.activation.migrateLegacyCodexAndroidHome = lib.hm.dag.entryAfter ["ensureMutableCodexConfig"] ''
    config_file=${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
    legacy_path=${lib.escapeShellArg "${config.home.homeDirectory}/Android/Sdk"}
    android_home=${lib.escapeShellArg "${config.home.homeDirectory}/Library/Android/sdk"}

    if [ -f "$config_file" ] && ${pkgs.gnugrep}/bin/grep -Fq -- "$legacy_path" "$config_file"; then
      verboseEcho "Updating the legacy Android SDK path in $config_file"
      LEGACY_PATH="$legacy_path" ANDROID_HOME="$android_home" ${pkgs.perl}/bin/perl -0pi -e 's/\Q$ENV{LEGACY_PATH}\E/$ENV{ANDROID_HOME}/g' "$config_file"
    fi
  '';
}
