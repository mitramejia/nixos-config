{config, ...}: {
  private.openCodeMutableConfigPlatform = {
    opencode = {
      plugins = ["opencode-claude-auth@latest"];
      seed = {
        model = "gpt-5.4";
        permission = "allow";
        plugin = ["opencode-claude-auth@latest"];
      };
    };
    tui.seed.keybinds.leader = "space";
  };

  assertions = [
    {
      assertion = let
        intent = config.private.openCodeMutableConfigIntent;
      in
        (builtins.elemAt intent 0).seed.model
        == "gpt-5.4"
        && (builtins.elemAt intent 0).seed.permission == "allow"
        && (builtins.elemAt intent 0).seed.plugin == ["opencode-claude-auth@latest"]
        && (builtins.elemAt intent 1).seed.keybinds.leader == "space";
      message = "Darwin OpenCode policy must retain its existing model, plugin, permission, and TUI settings.";
    }
  ];
}
