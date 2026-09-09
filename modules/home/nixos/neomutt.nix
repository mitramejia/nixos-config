{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.libsecret ];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
    sidebar.enable = true;

    macros = [
      {
        map = [
          "index"
          "pager"
        ];
        key = "gp";
        action = "<enter-command>source ${config.xdg.configHome}/neomutt/gmail-personal<enter><change-folder>+Inbox<enter>";
      }
      {
        map = [
          "index"
          "pager"
        ];
        key = "gc";
        action = "<enter-command>source ${config.xdg.configHome}/neomutt/gmail-comun<enter><change-folder>+Inbox<enter>";
      }
    ];
  };

  accounts.email.accounts = {
    gmail-personal = {
      primary = true;
      flavor = "gmail.com";
      address = "mitra.mejia@gmail.com";
      realName = "Mitra Mejia";
      userName = "mitra.mejia@gmail.com";
      passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup service neomutt account mitra.mejia@gmail.com";

      neomutt = {
        enable = true;
        mailboxType = "imap";
        mailboxName = "Personal Gmail";
      };

      smtp.tls = {
        enable = true;
        useStartTls = false;
      };
    };

    gmail-comun = {
      flavor = "gmail.com";
      address = "mitra@comun.app";
      realName = "Mitra Mejia";
      userName = "mitra@comun.app";
      passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup service neomutt account mitra@comun.app";

      neomutt = {
        enable = true;
        mailboxType = "imap";
        mailboxName = "Comun Gmail";
      };

      smtp.tls = {
        enable = true;
        useStartTls = false;
      };
    };
  };
}
