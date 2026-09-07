#!/usr/bin/env python3
"""Render the checked-in Herdr option reference."""
import json
from pathlib import Path
import sys

root = Path(__file__).resolve().parent.parent
reference = json.loads((root / "data/config-reference.json").read_text())
lines = [
    "# Herdr 0.9 settings", "",
    "Set these keys below `programs.herdr.settings` in either module.",
    "The table shows **upstream** defaults. The Nix default is `null` (omit the setting),",
    "except `onboarding` and `update.version_check`, which default to `false` when enabled.",
    "See [module options](modules.md) and the [advanced example](../examples/settings.nix).", "",
    "Generated from `data/config-reference.json` with `scripts/render-settings.py`.", "",
]
for section in reference["sections"]:
    lines += [f"## {section['title']}", "", "| Setting | Type / values | Upstream default |",
              "| --- | --- | --- |"]
    for entry in section["keys"]:
        value_type = ", ".join(f"`{value}`" for value in entry.get("values", [])) or entry["type"]
        if entry["key"] == "terminal.new_cwd":
            value_type = "string: `follow`, `home`, `current`, or a directory path"
        if entry["key"] == "ui.pane_borders":
            value_type += "; legacy boolean accepted"
        default = entry["default"].replace("|", "\\|")
        lines.append(f"| `{entry['key']}` | {value_type} | `{default}` |")
    lines.append("")
lines += [
    "## Compound settings", "",
    "`keys.command` is a list of records with `key`, `command`, `type`, `description`, `width`, and `height`.",
    "`key` accepts a string or a list of strings. `type` accepts `shell`, `pane`, `popup`, or `plugin_action`.",
    "Popup dimensions accept positive cell counts or percentage strings.", "",
    "`ui.tab_bar_right` accepts `zoom`, `hostname`, `datetime`, `text`, and `command` entries.",
    "Use `format` for datetime, `text` for literal text, and `command`, `interval_seconds`, and `timeout_seconds` for commands.", "",
    "Sidebar tokens accept a string or a record with `token`, `fg`, `bold`, `dim`, and `rules`.",
    "Each rule has one condition (`equals`, `contains`, `starts_with`, `gt`, or `lt`) and optional style fields.",
    "Text conditions also accept `ignore_case`. Row lists, rows, and rule lists are limited to 16 entries.", "",
    "The module also declares legacy `keys.fullscreen`, `advanced.scrollback_lines`, `ui.toast.enabled`, and `ui.agent_panel_scope`.",
    "The first two are aliases; `scrollback_lines` still measures bytes. `ui.agent_panel_scope` has no effect.", "",
    "Full descriptions are available in Home Manager's generated option manual and the [upstream configuration guide](https://herdr.dev/docs/configuration/).", "",
]
text = "\n".join(lines)
target = root / "docs/settings.md"
if sys.argv[1:]:
    sys.exit("Usage: render-settings.py")
target.write_text(text)
