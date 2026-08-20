{
  config,
  unstablePkgs,
  ...
}:
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.sessionVariables = {
    ANDROID_HOME = "${unstablePkgs.android-studio-full}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${unstablePkgs.android-studio-full}/libexec/android-sdk";
    ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
  };
}
