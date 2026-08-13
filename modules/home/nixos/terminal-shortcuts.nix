{...}: {
  programs.kitty.keybindings = {
    "super+c" = "copy_to_clipboard";
    "super+v" = "paste_from_clipboard";
    "super+x" = "send_key ctrl+x";
  };
}
