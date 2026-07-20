{
  host,
  inputs,
  ...
}: {
  nix-homebrew = {
    enable = true;
    user = host.username;
    autoMigrate = true;
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };
  };

  homebrew = {
    enable = true;
    casks = import ./casks.nix;
    onActivation.cleanup = "none";
  };
}
