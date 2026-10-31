{unstablePkgs}: let
  composition = unstablePkgs.androidenv.composeAndroidPackages {
    platformVersions = ["35" "36"];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = ["google_apis"];
    abiVersions = ["x86_64"];
    includeNDK = true;
  };
in
  unstablePkgs.android-studio.withSdk composition.androidsdk
