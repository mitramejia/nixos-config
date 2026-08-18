{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (import ../../../variables.nix) extraMonitorSettings browser terminal;

  workspaceIntent = [
    {
      workspace = "1";
      monitor = "DP-1";
      startupCommands = [browser];
      routes = [
        {
          tag = "browser*";
          routingOrder = 1;
        }
      ];
    }
    {
      workspace = "2";
      monitor = "DP-1";
      startupCommands = ["${terminal} -e herdr --session 2"];
      routes = [];
    }
    {
      workspace = "3";
      monitor = "DP-1";
      startupCommands = ["${terminal} -e herdr --session 3"];
      routes = [];
    }
    {
      workspace = "4";
      monitor = "DP-1";
      startupCommands = [];
      routes = [];
    }
    {
      workspace = "5";
      monitor = "DP-1";
      startupCommands = [
        "slack"
        "zapzap"
      ];
      routes = [
        {
          tag = "im*";
          routingOrder = 2;
        }
      ];
    }
    {
      workspace = "6";
      monitor = "DP-1";
      startupCommands = ["obsidian"];
      routes = [
        {
          class = "^(obsidian)$";
          routingOrder = 4;
        }
      ];
    }
    {
      workspace = "7";
      monitor = "DP-1";
      startupCommands = ["cider-appimage"];
      routes = [
        {
          class = "^(Cider)$";
          routingOrder = 5;
        }
      ];
    }
    {
      workspace = "8";
      monitor = "DP-1";
      startupCommands = [];
      routes = [
        {
          tag = "games*";
          routingOrder = 3;
        }
      ];
    }
    {
      workspace = "9";
      monitor = "DP-2";
      startupCommands = [terminal];
      routes = [];
    }
    {
      workspace = "10";
      monitor = "DP-2";
      startupCommands = [];
      routes = [];
    }
  ];

  appRoutingIntent = lib.concatLists (map ({
    workspace,
    routes,
    ...
  }:
    map (route: {
      inherit workspace;
      match = lib.removeAttrs route ["routingOrder"];
      inherit (route) routingOrder;
    })
    routes)
  workspaceIntent);

  workspaceNumbers = map ({workspace, ...}: workspace) workspaceIntent;

  hasDuplicateWorkspaceNumbers =
    lib.length workspaceNumbers != lib.length (lib.unique workspaceNumbers);

  hasDuplicateRoutingOrder = let
    routingOrders = map (entry: entry.routingOrder) appRoutingIntent;
  in
    lib.length routingOrders != lib.length (lib.unique routingOrders);

  orderedAppRoutingIntent = builtins.sort (routeA: routeB:
    routeA.routingOrder < routeB.routingOrder)
  appRoutingIntent;

  monitorByOutput = lib.listToAttrs (map (output: {
      name = output.output;
      value = output;
    })
    extraMonitorSettings);

  monitorAssignments = lib.unique (map ({monitor, ...}: monitor) workspaceIntent);

  knownMonitorAssignments = lib.filter (output: lib.hasAttr output monitorByOutput) monitorAssignments;
  workspaceMonitorOutputs = map (m: monitorByOutput.${m}) knownMonitorAssignments;

  missingMonitorAssignments =
    lib.filter (output: !lib.hasAttr output monitorByOutput) monitorAssignments;

  startupIntents = lib.concatMap ({
    workspace,
    startupCommands,
    ...
  }:
    map (command: {
      inherit workspace command;
    })
    startupCommands)
  workspaceIntent;

  mkWorkspaceRule = {
    workspace,
    monitor,
    ...
  }: {
    inherit workspace monitor;
    default = true;
  };

  workspaceRoutingWindowRules =
    map ({
      workspace,
      match,
      ...
    }: {
      inherit workspace match;
    })
    orderedAppRoutingIntent;
in {
  options = {
    private = {
      hyprlandWorkspaceIntent = {
        startupCommands = mkOption {
          type = types.listOf (types.submodule ({...}: {
            options = {
              workspace = mkOption {type = types.str;};
              command = mkOption {type = types.str;};
            };
          }));
          default = [];
          internal = true;
          description = ''
            Derived startup commands derived from workspace intent declarations.
            This option is intentionally private to the Hyprland Home Manager
            module set.
          '';
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = !hasDuplicateWorkspaceNumbers;
        message = "Hyprland workspace intent must declare unique workspace numbers.";
      }
      {
        assertion = missingMonitorAssignments == [];
        message = "Hyprland workspace intent references unknown monitor outputs.";
      }
      {
        assertion = !hasDuplicateRoutingOrder;
        message = "Hyprland routing routes must declare unique routingOrder values.";
      }
    ];

    private.hyprlandWorkspaceIntent.startupCommands = startupIntents;

    wayland.windowManager.hyprland.settings = {
      # Render monitor defaults as one hl.monitor call per output.
      monitor = workspaceMonitorOutputs;
      workspace_rule = map mkWorkspaceRule workspaceIntent;
      window_rule = workspaceRoutingWindowRules;
    };
  };
}
