{
  config,
  unstablePkgs,
  ...
}: let
  androidStudio = import ../../android-studio.nix {inherit unstablePkgs;};
in {
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.sessionVariables = {
    ANDROID_HOME = "${androidStudio}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidStudio}/libexec/android-sdk";
    ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
  };
}
