{...}: {
  programs.kitty.keybindings = {
    "super+c" = "copy_to_clipboard";
    "super+v" = "paste_from_clipboard";
    "super+x" = "send_key ctrl+x";
  };

  programs.ghostty.settings.keybind = [
    "performable:super+c=copy_to_clipboard:mixed"
    "super+v=paste_from_clipboard"
    "super+x=text:\\x18"
  ];
}
