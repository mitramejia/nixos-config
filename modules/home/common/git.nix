_: let
  inherit (import ../../variables.nix) gitUsername gitEmail;
in {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = gitUsername;
        email = gitEmail;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      credential.helper = "cache --timeout=7200";
      init.defaultBranch = "main";
      log.decorate = "full";
      log.date = "iso";
      merge.conflictStyle = "diff3";
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
