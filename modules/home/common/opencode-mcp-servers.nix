{
  config,
  lib,
  androidHome,
}:
let
  servers = (import ./mcp-servers.nix { inherit config androidHome; }).opencode;
in
lib.mapAttrs (
  _: server:
  if server ? url then
    server
  else
    (builtins.removeAttrs server [ "args" ])
    // {
      type = "local";
      command = [ server.command ] ++ server.args;
    }
) servers
