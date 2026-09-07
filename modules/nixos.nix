{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.herdr;
  files = import ../lib/files.nix { inherit lib pkgs; };
in
{
  imports = [ ./common.nix ];
  options.programs.herdr.extraFiles = lib.mkOption {
    type = files.type;
    default = { };
    description = "Additional system files below /etc/herdr, such as scripts and sounds.";
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.extraFiles ? "config.toml");
        message = "Herdr extraFiles cannot replace config.toml. Use settings instead.";
      }
    ];
    programs.herdr.finalPackage = (import ../lib/wrapper.nix { inherit lib pkgs; }) {
      inherit (cfg) package extraPackages;
      fallbackConfig = "/etc/herdr/config.toml";
    };
    environment.systemPackages = [ cfg.finalPackage ];
    environment.etc = {
      "herdr/config.toml".source = cfg.configFile;
    }
    // lib.mapAttrs' (
      name: file:
      lib.nameValuePair "herdr/${name}" {
        source = files.source name file;
        mode = if file.executable then "0755" else "0644";
      }
    ) cfg.extraFiles;
  };
}
