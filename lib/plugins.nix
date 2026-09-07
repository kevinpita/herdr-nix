{ lib, pkgs }:
{ package, plugins }:
let
  files = import ./files.nix { inherit lib pkgs; };
  link = name: plugin: ''
    herdr plugin link ${lib.escapeShellArg "${plugin.source}"} ${
      lib.optionalString (!plugin.enable) "--disabled"
    } > linked.json
    id=$(jq -er '.result.plugin.plugin_id' linked.json)
    printf '%s\n' "$id" >> ids
    config_dir=$(herdr plugin config-dir "$id")
    relative_dir="''${config_dir#"$XDG_CONFIG_HOME/herdr/"}"
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (fileName: file: ''
        target="$out/config/$relative_dir"/${lib.escapeShellArg fileName}
        mkdir -p "$(dirname "$target")"
        ln -s ${lib.escapeShellArg "${files.source fileName file}"} "$target"
      '') plugin.configFiles
    )}
  '';
in
pkgs.runCommand "herdr-plugins"
  {
    nativeBuildInputs = [
      package
      pkgs.jq
    ];
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_STATE_HOME="$HOME/.local/state"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    unset HERDR_SOCKET_PATH HERDR_SESSION HERDR_CONFIG_PATH
    mkdir -p "$XDG_CONFIG_HOME/herdr" "$XDG_RUNTIME_DIR" "$out/config/plugins/config"
    echo '[]' > "$XDG_CONFIG_HOME/herdr/plugins.json"
    touch ids
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList link plugins)}
    if [ "$(sort ids | uniq | wc -l)" -ne "$(wc -l < ids)" ]; then
      echo 'Duplicate Herdr plugin IDs. Each plugin manifest must have a unique ID.' >&2
      exit 1
    fi
    cp "$XDG_CONFIG_HOME/herdr/plugins.json" "$out/plugins.json"
  ''
