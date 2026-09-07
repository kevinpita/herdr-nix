{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.herdr;
  configLib = import ../lib/config.nix { inherit lib pkgs; };
in
{
  options.programs.herdr = {
    enable = lib.mkEnableOption "Herdr terminal workspaces";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage herdr-nix/package.nix { }";
      description = "Herdr package to install and use for validation.";
    };
    settings = lib.mkOption {
      type = import ./settings.nix { inherit lib pkgs; };
      default = { };
      description = ''
        Settings written to config.toml. Keys use the upstream TOML spelling.
        All documented 0.9.0 settings have types. Additional TOML keys are accepted
        and checked by Herdr at build time. Null omits a setting.
        Do not put secrets here: Nix store files are readable by all users.
      '';
      example = lib.literalExpression ''
        {
          theme.name = "catppuccin";
          keys.prefix = "ctrl+a";
          ui.pane_borders = "always";
          terminal.default_shell = "''${pkgs.fish}/bin/fish";
        }
      '';
    };
    validateConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run herdr config check on the generated file during the build.
        Disable for runtime-only sound paths, cross compilation, or a package
        with a different config contract. Check the installed file manually in that case.
      '';
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "with pkgs; [ git openssh lazygit ]";
      description = "Runtime tools added to the Herdr wrapper's PATH, including plugin dependencies.";
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = "Generated and, by default, validated TOML file.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Herdr package with the module's runtime environment.";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.herdr = {
      settings = {
        onboarding = lib.mkDefault false;
        update.version_check = lib.mkDefault false;
      };
      configFile = configLib.generate {
        inherit (cfg) settings package extraFiles;
        validate = cfg.validateConfig;
      };
    };
    assertions = [
      {
        assertion =
          (cfg.settings.ui.sidebar_min_width or null) == null
          || (cfg.settings.ui.sidebar_max_width or null) == null
          || cfg.settings.ui.sidebar_min_width <= cfg.settings.ui.sidebar_max_width;
        message = "programs.herdr.settings.ui.sidebar_min_width must not exceed sidebar_max_width.";
      }
    ];
  };
}
