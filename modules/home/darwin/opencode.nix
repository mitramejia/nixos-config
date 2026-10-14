{config, ...}: {
  private.openCodeMutableConfigPlatform = {
    opencode = {
      seed = {
        model = "gpt-5.4";
        permission = "allow";
      };
    };
    # Retain the private.tui alias; the shared reconciler writes V2 cli.json.
    tui.seed.keybinds.leader = "ctrl+x";
  };

  assertions = [
    {
      assertion = let
        intent = config.private.openCodeMutableConfigIntent;
      in
        (builtins.elemAt intent 0).seed.model
        == "gpt-5.4"
        && (builtins.elemAt intent 0).seed.permission == "allow"
        && (builtins.elemAt intent 1).seed.keybinds.leader == "ctrl+x";
      message = "Darwin OpenCode policy must retain its existing model, permission, and CLI settings.";
    }
  ];
}
