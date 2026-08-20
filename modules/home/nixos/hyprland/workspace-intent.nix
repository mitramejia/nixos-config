{
  config,
  lib,
  pkgs,
  ...
}: let
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

  monitorByOutput = lib.listToAttrs (map (output: {
      name = output.output;
      value = output;
    })
    extraMonitorSettings);

  mkWorkspaceIntent = declarations: let
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
    declarations);
    workspaceNumbers = map ({workspace, ...}: workspace) declarations;
    monitorAssignments = lib.unique (map ({monitor, ...}: monitor) declarations);
    missingMonitorAssignments =
      lib.filter (output: !lib.hasAttr output monitorByOutput) monitorAssignments;
    orderedAppRoutingIntent = builtins.sort (routeA: routeB:
      routeA.routingOrder < routeB.routingOrder)
    appRoutingIntent;
    startupCommands = lib.concatMap ({
      workspace,
      startupCommands,
      ...
    }:
      map (command: {
        inherit workspace command;
      })
      startupCommands)
    declarations;
  in {
    inherit declarations missingMonitorAssignments startupCommands;
    monitorSettings = map (monitor: monitorByOutput.${monitor}) monitorAssignments;
    workspaceRules =
      map ({
        workspace,
        monitor,
        ...
      }: {
        inherit workspace monitor;
        default = true;
      })
      declarations;
    routingRules =
      map ({
        workspace,
        match,
        ...
      }: {
        inherit workspace match;
      })
      orderedAppRoutingIntent;
    invariants = {
      uniqueWorkspaceNumbers =
        lib.length workspaceNumbers == lib.length (lib.unique workspaceNumbers);
      knownMonitorAssignments = missingMonitorAssignments == [];
      uniqueRoutingOrder = let
        routingOrders = map (entry: entry.routingOrder) appRoutingIntent;
      in
        lib.length routingOrders == lib.length (lib.unique routingOrders);
    };
  };

  workspace = mkWorkspaceIntent workspaceIntent;

  representativeWorkspace = mkWorkspaceIntent [
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
      workspace = "9";
      monitor = "DP-2";
      startupCommands = [terminal];
      routes = [];
    }
  ];

  duplicateWorkspace = mkWorkspaceIntent [
    {
      workspace = "1";
      monitor = "DP-1";
      startupCommands = [];
      routes = [];
    }
    {
      workspace = "1";
      monitor = "DP-2";
      startupCommands = [];
      routes = [];
    }
  ];

  unknownMonitorWorkspace = mkWorkspaceIntent [
    {
      workspace = "1";
      monitor = "UNKNOWN";
      startupCommands = [];
      routes = [];
    }
  ];

  duplicateRoutingOrderWorkspace = mkWorkspaceIntent [
    {
      workspace = "1";
      monitor = "DP-1";
      startupCommands = [];
      routes = [
        {
          tag = "browser*";
          routingOrder = 1;
        }
        {
          tag = "im*";
          routingOrder = 1;
        }
      ];
    }
  ];

  workspaceCheck = let
    inherit (lib) assertMsg drop;
    hyprlandSettings = config.wayland.windowManager.hyprland.settings;
    finalWindowRules = hyprlandSettings.window_rule;
    routingRuleSuffix =
      if builtins.length finalWindowRules >= builtins.length workspace.routingRules
      then drop (builtins.length finalWindowRules - builtins.length workspace.routingRules) finalWindowRules
      else [];
  in
    assert assertMsg workspace.invariants.uniqueWorkspaceNumbers "Hyprland workspace intent must declare unique workspace numbers.";
    assert assertMsg workspace.invariants.knownMonitorAssignments "Hyprland workspace intent references unknown monitor outputs.";
    assert assertMsg workspace.invariants.uniqueRoutingOrder "Hyprland routing routes must declare unique routingOrder values.";
    assert assertMsg (representativeWorkspace.workspaceRules
      == [
        {
          workspace = "1";
          monitor = "DP-1";
          default = true;
        }
        {
          workspace = "9";
          monitor = "DP-2";
          default = true;
        }
      ]) "Workspace declarations must derive monitor assignments.";
    assert assertMsg (representativeWorkspace.routingRules
      == [
        {
          workspace = "1";
          match = {tag = "browser*";};
        }
      ]) "Workspace routes must derive in routing order.";
    assert assertMsg (representativeWorkspace.startupCommands
      == [
        {
          workspace = "1";
          command = "zen-beta";
        }
        {
          workspace = "9";
          command = "kitty";
        }
      ]) "Workspace declarations must derive structured startup commands.";
    assert assertMsg (!duplicateWorkspace.invariants.uniqueWorkspaceNumbers) "Duplicate workspace numbers must be rejected.";
    assert assertMsg (!unknownMonitorWorkspace.invariants.knownMonitorAssignments) "Unknown monitor assignments must be rejected.";
    assert assertMsg (!duplicateRoutingOrderWorkspace.invariants.uniqueRoutingOrder) "Duplicate routing order values must be rejected.";
    assert assertMsg (hyprlandSettings.monitor == workspace.monitorSettings) "Workspace intent must render monitor settings.";
    assert assertMsg (hyprlandSettings.workspace_rule == workspace.workspaceRules) "Workspace intent must render workspace rules.";
    assert assertMsg (routingRuleSuffix == workspace.routingRules) "Workspace routing rules must be last in final Hyprland settings.";
    assert assertMsg (config.private.hyprlandWorkspaceIntent.startupCommands == workspace.startupCommands) "Workspace intent must expose startup commands to the Lua adapter.";
      pkgs.runCommand "hyprland-workspace-intent" {} "mkdir -p $out";
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
            Startup commands derived from workspace intent declarations.
            This option is intentionally private to the Hyprland Home Manager
            module set.
          '';
        };
        check = mkOption {
          type = types.package;
          internal = true;
          description = "Focused workspace-intent verification result.";
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = workspace.invariants.uniqueWorkspaceNumbers;
        message = "Hyprland workspace intent must declare unique workspace numbers.";
      }
      {
        assertion = workspace.invariants.knownMonitorAssignments;
        message = "Hyprland workspace intent references unknown monitor outputs.";
      }
      {
        assertion = workspace.invariants.uniqueRoutingOrder;
        message = "Hyprland routing routes must declare unique routingOrder values.";
      }
    ];

    private.hyprlandWorkspaceIntent = {
      startupCommands = workspace.startupCommands;
      check = workspaceCheck;
    };

    wayland.windowManager.hyprland.settings = {
      # Render monitor defaults as one hl.monitor call per output.
      monitor = workspace.monitorSettings;
      workspace_rule = workspace.workspaceRules;
      window_rule = lib.mkAfter workspace.routingRules;
    };
  };
}
