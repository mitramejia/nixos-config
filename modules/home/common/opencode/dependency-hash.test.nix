let
  correct = import ./dependency-hash.nix;
  current = {
    system = "aarch64-darwin";
    rev = "0749024f0d6f6bb3014850a820d06677b7c37120";
    version = "2.1.4+0749024";
    hash = "sha256-TO9ubp4SLWrzWJY1BgDKOy/S8Tcws+Z2k+I6ba/TkWk=";
  };
in {
  currentDarwin = correct current == "sha256-3EGfe+K2yM4atFT70JcwY66i/wFvHPO6/ewiIa2SB5Q=";
  linuxUntouched = correct (current // {system = "x86_64-linux";}) == current.hash;
  otherDarwinUntouched = correct (current // {system = "x86_64-darwin";}) == current.hash;
  futureRevisionUntouched = correct (current // {rev = "future-revision";}) == current.hash;
  differentVersionUntouched = correct (current // {version = "2.1.5";}) == current.hash;
  changedUpstreamHashUntouched = correct (current // {hash = "new-upstream-hash";}) == "new-upstream-hash";
}
