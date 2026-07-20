{...}: {
  programs.git = {
    ignores = ["*.swp"];
    lfs.enable = true;
    settings = {
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = false;
      pull.rebase = false;
    };
  };
}
