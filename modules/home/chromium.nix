{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # redux devtools
      {id = "fmkadmapgofadopljbjfkapdkoienihi";} # react devtools
      {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # vimium
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };
}
