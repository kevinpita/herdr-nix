{ lib, pkgs }:
let
  inherit (lib) types mkOption;
  toml = pkgs.formats.toml { };
  reference = builtins.fromJSON (builtins.readFile ../data/config-reference.json);
  entries = lib.concatMap (section: section.keys) reference.sections;
  optional =
    type: description:
    mkOption {
      type = types.nullOr type;
      default = null;
      inherit description;
    };
  table =
    options:
    types.submodule {
      freeformType = toml.type;
      inherit options;
    };
  binding = types.either types.str (types.listOf types.str);
  boundedList = type: types.addCheck (types.listOf type) (xs: builtins.length xs <= 16);
  uint16 = types.ints.between 0 65535;
  style = {
    fg = optional (types.strMatching "#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})") "Foreground color in #RGB or #RRGGBB form.";
    bold = optional types.bool "Use bold text. False removes bold text.";
    dim = optional types.bool "Use dim text. False removes dim text.";
  };
  rule = table (
    style
    // {
      equals = optional types.str "Match the complete text value.";
      contains = optional types.str "Match a text substring.";
      starts_with = optional types.str "Match the start of the text value.";
      gt = optional types.number "Match a numeric value above this threshold.";
      lt = optional types.number "Match a numeric value below this threshold.";
      ignore_case = optional types.bool "Ignore ASCII case in a text condition.";
    }
  );
  token = types.either types.str (
    table (
      style
      // {
        token = mkOption {
          type = types.str;
          description = "Built-in token or $name metadata token.";
        };
        rules = optional (boundedList rule) "Ordered style rules. Exactly one condition per rule; the first match wins.";
      }
    )
  );
  rows = boundedList (boundedList token);
  statusEntry = table {
    type = mkOption {
      type = types.enum [
        "zoom"
        "hostname"
        "datetime"
        "text"
        "command"
      ];
      description = "Tab bar entry type.";
    };
    format = optional types.str "Datetime format, such as %H:%M.";
    text = optional types.str "Literal text for a text entry.";
    command = optional types.str "Shell command for a command entry.";
    interval_seconds = optional (types.ints.between 1 31536000) "Command refresh interval in seconds.";
    timeout_seconds = optional (types.ints.between 1 3600) "Command timeout in seconds.";
  };
  popupSize = types.either (types.ints.between 1 65535) (types.strMatching "[0-9]+%");
  command = table {
    key = mkOption {
      type = binding;
      description = "Shortcut or list of shortcuts.";
    };
    command = mkOption {
      type = types.str;
      description = "Shell command or qualified plugin action ID.";
    };
    type = optional (types.enum [
      "shell"
      "pane"
      "popup"
      "plugin_action"
    ]) "Execution mode. Herdr defaults to shell.";
    description = optional types.str "Text shown in keybinding help.";
    width = optional popupSize "Popup width in cells or percent.";
    height = optional popupSize "Popup height in cells or percent.";
  };
  integerType =
    key:
    if lib.hasPrefix "server." key then
      types.ints.between 1 65535
    else if key == "ui.toast.delay_seconds" then
      types.ints.between 0 3600
    else if key == "ui.mouse_scroll_lines" then
      types.ints.positive
    else if lib.hasPrefix "ui." key then
      uint16
    else
      types.ints.unsigned;
  entryType =
    entry:
    if entry.key == "terminal.new_cwd" then
      types.str
    else if entry.key == "ui.pane_borders" then
      types.either types.bool (types.enum entry.values)
    else if entry.key == "ui.agent_panel_sort" then
      types.enum (entry.values ++ [ "workspaces" ])
    else if entry.type == "boolean" then
      types.bool
    else if entry.type == "integer" then
      integerType entry.key
    else if entry.type == "enum" then
      types.enum entry.values
    else if entry.type == "keybinding" then
      binding
    else if entry.type == "list of strings" then
      types.listOf types.str
    else if entry.type == "list of token rows" then
      rows
    else if entry.type == "table of token rows" then
      types.attrsOf rows
    else if entry.key == "ui.tab_bar_right" then
      boundedList statusEntry
    else if
      builtins.elem entry.type [
        "string"
        "color"
        "path"
      ]
    then
      types.str
    else
      throw "Unmapped Herdr configuration type: ${entry.type} (${entry.key})";
  leaves = lib.foldl' lib.recursiveUpdate { } (
    map (
      entry:
      lib.setAttrByPath (lib.splitString "." entry.key) (
        optional (entryType entry) (
          entry.description + " Upstream default: " + entry.default + ". Null leaves this setting unset."
        )
      )
    ) entries
  );
  nested =
    tree:
    lib.mapAttrs (
      _: value:
      if lib.isOption value then
        value
      else
        mkOption {
          type = table (nested value);
          default = { };
          description = "Herdr configuration table. Unset values use upstream defaults.";
        }
    ) tree;
in
table (
  nested (
    lib.recursiveUpdate leaves {
      keys.command = optional (types.listOf command) "Custom command keybindings, in order.";
      keys.fullscreen = optional binding "Legacy alias for keys.zoom. Prefer zoom in new configurations.";
      advanced.scrollback_lines = optional types.ints.unsigned "Legacy alias for scrollback_limit_bytes. The value is bytes, not lines.";
      ui.toast.enabled = optional types.bool "Legacy toast switch. Prefer ui.toast.delivery.";
      ui.agent_panel_scope = optional (types.enum [
        "current"
        "all"
      ]) "Retired setting accepted by Herdr for compatibility. It has no effect.";
    }
  )
)
