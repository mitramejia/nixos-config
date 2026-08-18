{
  host,
  inputs,
  unstablePkgs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit host inputs unstablePkgs;
    };
    users.${host.username}.imports = [
      ../home/common
      ../home/darwin
    ];
  };
}
