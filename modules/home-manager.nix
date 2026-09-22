{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.programs.herdr;
  files = import ../lib/files.nix { inherit lib pkgs; };
  pluginType = types.coercedTo types.path (source: { inherit source; }) (
    types.submodule {
      options = {
        source = mkOption {
          type = types.path;
          description = "Built plugin directory containing herdr-plugin.toml. Accepts a path or package. Build steps must run in its Nix derivation.";
        };
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Register the plugin as enabled. False keeps it installed but disabled.";
        };
        configFiles = mkOption {
          type = files.type;
          default = { };
          description = "Files under the plugin's config directory. Values are paths or { text = ...; } / { source = ...; }. Keep credentials outside the Nix store.";
        };
      };
    }
  );
  plugins = import ../lib/plugins.nix { inherit lib pkgs; } {
    inherit (cfg) package;
    plugins = if cfg.plugins == null then { } else cfg.plugins;
  };
  machineType = types.submodule (
    { name, ... }: {
      options = {
        id = mkOption {
          type = types.strMatching "[0-9a-f]{32}";
          default = builtins.substring 0 32 (builtins.hashString "sha256" name);
          defaultText = "First 32 hexadecimal characters of SHA-256 of the attribute name";
          description = "Stable profile ID. Set this when importing an existing machine.";
        };
        label = mkOption {
          type = types.str;
          default = name;
          description = "Machine label shown in the UI.";
        };
        target = mkOption {
          type = types.str;
          description = "OpenSSH host alias or SSH target. Do not include passwords.";
        };
        session = mkOption {
          type = types.str;
          default = "default";
          description = "Remote Herdr session name.";
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
          description = "Connect to this machine when the client starts.";
        };
      };
    }
  );
  machineFile = (pkgs.formats.json { }).generate "herdr-endpoints.json" {
    version = 1;
    ssh = lib.attrValues (if cfg.machines == null then { } else cfg.machines);
  };
  checkedMachines = pkgs.runCommand "herdr-endpoints.json" { nativeBuildInputs = [ cfg.package ]; } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_STATE_HOME="$HOME/.local/state"
    mkdir -p "$XDG_STATE_HOME/herdr/client"
    cp ${machineFile} "$XDG_STATE_HOME/herdr/client/endpoints.json"
    herdr machine list --json
    cp ${machineFile} "$out"
  '';
in
{
  disabledModules = [ "programs/herdr.nix" ];
  imports = [ ./common.nix ];
  options.programs.herdr = {
    plugins = mkOption {
      type = types.nullOr (types.attrsOf pluginType);
      default = null;
      description = ''
        Declarative plugin registry. Attribute names are Nix labels; the manifest
        supplies the plugin ID. Null leaves the registry unmanaged. An empty set
        manages an empty registry. Nix owns the full registry, not a merge with CLI installs.
      '';
      example = lib.literalExpression "{ layout = ./plugins/layout; }";
    };
    extraFiles = mkOption {
      type = files.type;
      default = { };
      description = "Additional files below $XDG_CONFIG_HOME/herdr, such as scripts and sounds. Use a path or { text = ...; }.";
    };
    machines = mkOption {
      type = types.nullOr (types.attrsOf machineType);
      default = null;
      description = ''
        Saved SSH machines. Null leaves the catalog unmanaged; an empty set removes
        declarative entries. OpenSSH owns authentication. The remote Herdr installation
        must already be prepared. Activation does not connect or install remote software.
        Current client selection stays in its separate writable state file.
      '';
      example = {
        build = {
          target = "build-host";
          session = "work";
        };
      };
    };
    integrations = mkOption {
      type = types.listOf (
        types.enum [
          "pi"
          "omp"
          "claude"
          "codex"
          "copilot"
          "devin"
          "droid"
          "kimi"
          "opencode"
          "kilo"
          "hermes"
          "qodercli"
          "qwen"
          "cursor"
          "mastracode"
          "antigravity-cli"
          "grok"
          "letta"
        ]
      );
      default = [ ];
      description = ''
        Opt-in upstream integration installers run during activation. They update
        other agents' writable configuration files and can fail on Nix-owned files.
        Removing a name stops installation; it does not uninstall existing hooks.
        Use herdr integration uninstall TARGET to remove them explicitly.
      '';
    };
    skillDirectories = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        ".claude/skills/herdr"
        ".agents/skills/herdr"
      ];
      description = "Home-relative directories in which to install the bundled Herdr skill.";
    };
    server = {
      enable = lib.mkEnableOption "a systemd user service for a headless Herdr server";
      session = mkOption {
        type = types.addCheck (types.strMatching "[A-Za-z0-9_.-]+") (
          value:
          builtins.stringLength value <= 64
          && !(builtins.elem value [
            "."
            ".."
          ])
        );
        default = "default";
        description = "Session owned by the service. Stop an existing manual server before enabling it.";
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.server.enable || pkgs.stdenv.hostPlatform.isLinux;
        message = "programs.herdr.server requires Linux and systemd user services.";
      }
      {
        assertion = lib.all files.validName cfg.skillDirectories;
        message = "programs.herdr.skillDirectories must contain safe home-relative paths.";
      }
      {
        assertion = lib.all (
          name:
          name != "config.toml"
          && name != "plugins.json"
          && name != "plugins"
          && !(lib.hasPrefix "plugins/" name)
        ) (lib.attrNames cfg.extraFiles);
        message = "Herdr extraFiles cannot replace config.toml or plugin-managed paths.";
      }
    ];
    programs.herdr.finalPackage = (import ../lib/wrapper.nix { inherit lib pkgs; }) {
      inherit (cfg) package extraPackages;
    };
    home.packages = [ cfg.finalPackage ];
    xdg.configFile = lib.mkMerge [
      { "herdr/config.toml".source = cfg.configFile; }
      (mkIf (cfg.plugins != null) {
        "herdr/plugins.json".source = "${plugins}/plugins.json";
        "herdr/plugins/config" = {
          source = "${plugins}/config/plugins/config";
          recursive = true;
        };
      })
      (lib.mapAttrs' (
        name: file:
        lib.nameValuePair "herdr/${name}" {
          source = files.source name file;
        }
      ) cfg.extraFiles)
    ];
    home.file = lib.mkMerge [
      (lib.genAttrs cfg.skillDirectories (_: {
        source = "${cfg.package}/share/herdr/skills/herdr";
      }))
      (mkIf (cfg.machines != null) {
        "${config.xdg.stateHome}/herdr/client/endpoints.json".source = checkedMachines;
      })
    ];
    home.activation.herdrIntegrations = mkIf (cfg.integrations != [ ]) (
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] (
        lib.concatMapStringsSep "\n" (
          target:
          "run env XDG_CONFIG_HOME=${lib.escapeShellArg config.xdg.configHome} XDG_STATE_HOME=${lib.escapeShellArg config.xdg.stateHome} ${lib.getExe cfg.finalPackage} integration install ${lib.escapeShellArg target}"
        ) (lib.unique cfg.integrations)
      )
    );
    systemd.user.services.herdr = mkIf cfg.server.enable {
      Unit.Description = "Herdr headless terminal server";
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.finalPackage} --session ${cfg.server.session} server";
        ExecReload = "${lib.getExe cfg.finalPackage} --session ${cfg.server.session} server reload-config";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = [
          "HERDR_CONFIG_PATH=${config.xdg.configHome}/herdr/config.toml"
          "XDG_CONFIG_HOME=${config.xdg.configHome}"
          "XDG_STATE_HOME=${config.xdg.stateHome}"
          "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        ];
      };
    };
  };
}
