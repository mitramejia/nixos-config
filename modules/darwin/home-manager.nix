{
  host,
  inputs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit host inputs;
    };
    users.${host.username}.imports = [
      ../home/common
      ../home/darwin
    ];
  };
}
