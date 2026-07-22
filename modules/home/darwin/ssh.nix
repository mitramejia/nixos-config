_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = ["~/.ssh/config_external"];
    settings = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/github_id"
          "~/.ssh/comun_github_id"
        ];
      };
    };
  };
}
