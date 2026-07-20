# starship is a minimal, fast, and extremely customizable prompt for any shell!
{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    settings = {
      command_timeout = 5000;
    };
  };
}
