{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.vivaldi;
    extensions = [
      {id = "lmhkpmbekcpmknklioeibfkpmmfibljd";} # redux devtools
      {id = "fmkadmapgofadopljbjfkapdkoienihi";} # react devtools
      {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # vimium
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };
}
