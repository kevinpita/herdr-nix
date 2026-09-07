{ lib, pkgs }:
let
  inherit (lib) types;
  validName =
    name:
    name != ""
    && !(lib.hasPrefix "/" name)
    && lib.all (
      part:
      !(builtins.elem part [
        ""
        "."
        ".."
      ])
    ) (lib.splitString "/" name);
  fileType = types.coercedTo types.path (source: { inherit source; }) (
    types.submodule {
      options = {
        source = lib.mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Source file in the Nix store. Set either source or text.";
        };
        text = lib.mkOption {
          type = types.nullOr types.lines;
          default = null;
          description = "File contents. Do not include secrets.";
        };
        executable = lib.mkOption {
          type = types.bool;
          default = false;
          description = "Make a text file executable.";
        };
      };
    }
  );
  source =
    name: file:
    if !validName name then
      throw "Unsafe Herdr file name: ${name}"
    else if (file.source == null) == (file.text == null) then
      throw "Herdr file ${name}: set exactly one of source and text"
    else if file.source != null then
      file.source
    else
      pkgs.writeTextFile {
        name = "herdr-${builtins.baseNameOf name}";
        inherit (file) text executable;
      };
in
{
  inherit fileType source validName;
  type = types.attrsOf fileType;
}
