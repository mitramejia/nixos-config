{...}: let
  inherit (import ../variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";

    difftastic = {enable = true;};
    extraConfig = {
      push = {
        default = "simple"; # Match modern push behavior
        autoSetupRemote = true;
      };
      # FOSS-friendly settings
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main"; # Set default new branches to 'main'
      log.decorate = "full"; # Show branch/tag info in git log
      log.date = "iso"; # ISO 8601 date format
      # Conflict resolution style for readable diffs
      merge.conflictStyle = "diff3";
    };
  };
}
