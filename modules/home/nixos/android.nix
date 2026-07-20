{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  home.packages = with pkgs; [
    android-studio
  ];

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
    ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
  };
}
