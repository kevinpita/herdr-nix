{ lib, pkgs }:
{
  package,
  extraPackages ? [ ],
  fallbackConfig ? null,
}:
if extraPackages == [ ] && fallbackConfig == null then
  package
else
  pkgs.symlinkJoin {
    name = "herdr-configured-${package.version or "local"}";
    paths = [ package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/herdr" \
        ${
          lib.optionalString (
            extraPackages != [ ]
          ) "--prefix PATH : ${lib.escapeShellArg (lib.makeBinPath extraPackages)}"
        } \
        ${lib.optionalString (fallbackConfig != null) (
          "--run "
          + lib.escapeShellArg ''
            if [ -z "''${HERDR_CONFIG_PATH+x}" ] && [ ! -e "''${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml" ]; then
              export HERDR_CONFIG_PATH=${lib.escapeShellArg fallbackConfig}
            fi
          ''
        )}
    '';
    inherit (package) meta;
    passthru = {
      inherit package;
      version = package.version or "local";
    };
  }
