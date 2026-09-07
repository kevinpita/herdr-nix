{ lib, pkgs }:
let
  files = import ./files.nix { inherit lib pkgs; };
  clean =
    value:
    if builtins.isAttrs value then
      lib.filterAttrs (_: v: v != null && v != { }) (lib.mapAttrs (_: clean) value)
    else if builtins.isList value then
      map clean value
    else
      value;
in
{
  inherit clean;
  generate =
    {
      settings,
      package,
      validate ? true,
      extraFiles ? { },
    }:
    let
      raw = (pkgs.formats.toml { }).generate "herdr-config.toml" (clean settings);
    in
    if !validate then
      raw
    else
      pkgs.runCommand "herdr-config.toml"
        {
          nativeBuildInputs = [ package ];
        }
        ''
          export HOME="$TMPDIR/home"
          export XDG_CONFIG_HOME="$HOME/.config"
          export XDG_STATE_HOME="$HOME/.local/state"
          export HERDR_CONFIG_PATH="$XDG_CONFIG_HOME/herdr/config.toml"
          mkdir -p "$XDG_CONFIG_HOME/herdr"
          cp ${raw} "$HERDR_CONFIG_PATH"
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: file: ''
              target="$XDG_CONFIG_HOME/herdr"/${lib.escapeShellArg name}
              mkdir -p "$(dirname "$target")"
              ln -s ${lib.escapeShellArg "${files.source name file}"} "$target"
            '') extraFiles
          )}
          herdr config check
          cp ${raw} "$out"
        '';
}
