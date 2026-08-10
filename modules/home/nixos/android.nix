{config, ...}: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
    ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
  };
}
