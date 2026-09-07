# Herdr 0.9 settings

Set these keys below `programs.herdr.settings` in either module.
The table shows **upstream** defaults. The Nix default is `null` (omit the setting),
except `onboarding` and `update.version_check`, which default to `false` when enabled.
See [module options](modules.md) and the [advanced example](../examples/settings.nix).

Generated from `data/config-reference.json` with `scripts/render-settings.py`.

## General

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `onboarding` | boolean | `unset` |

## Server

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `server.headless_cols` | integer | `120` |
| `server.headless_rows` | integer | `40` |

## Theme

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `theme.name` | string | `"catppuccin"` |
| `theme.auto_switch` | boolean | `false` |
| `theme.dark_name` | string | `unset` |
| `theme.light_name` | string | `unset` |
| `theme.custom.accent` | color | `unset` |
| `theme.custom.panel_bg` | color | `unset` |
| `theme.custom.sidebar_bg` | color | `unset` |
| `theme.custom.active_row_bg` | color | `unset` |
| `theme.custom.selection_bg` | color | `unset` |
| `theme.custom.surface0` | color | `unset` |
| `theme.custom.surface1` | color | `unset` |
| `theme.custom.surface_dim` | color | `unset` |
| `theme.custom.overlay0` | color | `unset` |
| `theme.custom.overlay1` | color | `unset` |
| `theme.custom.text` | color | `unset` |
| `theme.custom.subtext0` | color | `unset` |
| `theme.custom.mauve` | color | `unset` |
| `theme.custom.green` | color | `unset` |
| `theme.custom.yellow` | color | `unset` |
| `theme.custom.red` | color | `unset` |
| `theme.custom.blue` | color | `unset` |
| `theme.custom.teal` | color | `unset` |
| `theme.custom.peach` | color | `unset` |
| `theme.custom.light.accent` | color | `unset` |
| `theme.custom.light.panel_bg` | color | `unset` |
| `theme.custom.light.sidebar_bg` | color | `unset` |
| `theme.custom.light.active_row_bg` | color | `unset` |
| `theme.custom.light.selection_bg` | color | `unset` |
| `theme.custom.light.surface0` | color | `unset` |
| `theme.custom.light.surface1` | color | `unset` |
| `theme.custom.light.surface_dim` | color | `unset` |
| `theme.custom.light.overlay0` | color | `unset` |
| `theme.custom.light.overlay1` | color | `unset` |
| `theme.custom.light.text` | color | `unset` |
| `theme.custom.light.subtext0` | color | `unset` |
| `theme.custom.light.mauve` | color | `unset` |
| `theme.custom.light.green` | color | `unset` |
| `theme.custom.light.yellow` | color | `unset` |
| `theme.custom.light.red` | color | `unset` |
| `theme.custom.light.blue` | color | `unset` |
| `theme.custom.light.teal` | color | `unset` |
| `theme.custom.light.peach` | color | `unset` |
| `theme.custom.dark.accent` | color | `unset` |
| `theme.custom.dark.panel_bg` | color | `unset` |
| `theme.custom.dark.sidebar_bg` | color | `unset` |
| `theme.custom.dark.active_row_bg` | color | `unset` |
| `theme.custom.dark.selection_bg` | color | `unset` |
| `theme.custom.dark.surface0` | color | `unset` |
| `theme.custom.dark.surface1` | color | `unset` |
| `theme.custom.dark.surface_dim` | color | `unset` |
| `theme.custom.dark.overlay0` | color | `unset` |
| `theme.custom.dark.overlay1` | color | `unset` |
| `theme.custom.dark.text` | color | `unset` |
| `theme.custom.dark.subtext0` | color | `unset` |
| `theme.custom.dark.mauve` | color | `unset` |
| `theme.custom.dark.green` | color | `unset` |
| `theme.custom.dark.yellow` | color | `unset` |
| `theme.custom.dark.red` | color | `unset` |
| `theme.custom.dark.blue` | color | `unset` |
| `theme.custom.dark.teal` | color | `unset` |
| `theme.custom.dark.peach` | color | `unset` |

## Terminal

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `terminal.default_shell` | string | `""` |
| `terminal.shell_mode` | `auto`, `login`, `non_login` | `"auto"` |
| `terminal.new_cwd` | string: `follow`, `home`, `current`, or a directory path | `"follow"` |
| `terminal.kitty_graphics` | boolean | `true` |

## Updates

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `update.channel` | `stable`, `preview` | `"stable" ("preview" for Windows preview builds)` |
| `update.version_check` | boolean | `true` |
| `update.manifest_check` | boolean | `true` |

## Keybindings

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `keys.prefix` | string | `"ctrl+b"` |
| `keys.help` | keybinding | `"prefix+?"` |
| `keys.settings` | keybinding | `"prefix+s"` |
| `keys.new_workspace` | keybinding | `"prefix+shift+n"` |
| `keys.new_worktree` | keybinding | `"prefix+shift+g"` |
| `keys.open_worktree` | keybinding | `unset` |
| `keys.remove_worktree` | keybinding | `unset` |
| `keys.rename_workspace` | keybinding | `"prefix+shift+w"` |
| `keys.close_workspace` | keybinding | `"prefix+shift+d"` |
| `keys.workspace_picker` | keybinding | `"prefix+w"` |
| `keys.goto` | keybinding | `"prefix+g"` |
| `keys.navigate_workspace_up` | keybinding | `"up"` |
| `keys.navigate_workspace_down` | keybinding | `"down"` |
| `keys.navigate_pane_left` | keybinding | `"h"` |
| `keys.navigate_pane_down` | keybinding | `"j"` |
| `keys.navigate_pane_up` | keybinding | `"k"` |
| `keys.navigate_pane_right` | keybinding | `"l"` |
| `keys.detach` | keybinding | `"prefix+q"` |
| `keys.reload_config` | keybinding | `"prefix+shift+r"` |
| `keys.open_notification_target` | keybinding | `"prefix+o"` |
| `keys.previous_workspace` | keybinding | `unset` |
| `keys.next_workspace` | keybinding | `unset` |
| `keys.previous_agent` | keybinding | `unset` |
| `keys.next_agent` | keybinding | `unset` |
| `keys.focus_agent` | keybinding | `unset` |
| `keys.remote_image_paste` | string | `"ctrl+v"` |
| `keys.new_tab` | keybinding | `"prefix+c"` |
| `keys.rename_tab` | keybinding | `"prefix+shift+t"` |
| `keys.previous_tab` | keybinding | `"prefix+p"` |
| `keys.next_tab` | keybinding | `"prefix+n"` |
| `keys.move_tab_previous` | keybinding | `unset` |
| `keys.move_tab_next` | keybinding | `unset` |
| `keys.switch_tab` | keybinding | `"prefix+1..9"` |
| `keys.switch_workspace` | keybinding | `unset` |
| `keys.close_tab` | keybinding | `"prefix+shift+x"` |
| `keys.rename_pane` | keybinding | `"prefix+shift+p"` |
| `keys.edit_scrollback` | keybinding | `"prefix+e"` |
| `keys.copy_mode` | keybinding | `"prefix+["` |
| `keys.focus_pane_left` | keybinding | `"prefix+h"` |
| `keys.focus_pane_down` | keybinding | `"prefix+j"` |
| `keys.focus_pane_up` | keybinding | `"prefix+k"` |
| `keys.focus_pane_right` | keybinding | `"prefix+l"` |
| `keys.swap_pane_left` | keybinding | `"prefix+shift+h"` |
| `keys.swap_pane_down` | keybinding | `"prefix+shift+j"` |
| `keys.swap_pane_up` | keybinding | `"prefix+shift+k"` |
| `keys.swap_pane_right` | keybinding | `"prefix+shift+l"` |
| `keys.cycle_pane_next` | keybinding | `"prefix+tab"` |
| `keys.cycle_pane_previous` | keybinding | `"prefix+shift+tab"` |
| `keys.last_pane` | keybinding | `unset` |
| `keys.split_vertical` | keybinding | `"prefix+v"` |
| `keys.split_horizontal` | keybinding | `"prefix+minus"` |
| `keys.close_pane` | keybinding | `"prefix+x"` |
| `keys.zoom` | keybinding | `"prefix+z"` |
| `keys.resize_mode` | keybinding | `"prefix+r"` |
| `keys.resize_pane_left` | keybinding | `unset` |
| `keys.resize_pane_down` | keybinding | `unset` |
| `keys.resize_pane_up` | keybinding | `unset` |
| `keys.resize_pane_right` | keybinding | `unset` |
| `keys.toggle_sidebar` | keybinding | `"prefix+b"` |
| `keys.indexed.tabs` | string | `unset` |
| `keys.indexed.workspaces` | string | `unset` |
| `keys.indexed.agents` | string | `unset` |

## UI and sidebar

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `ui.sidebar_width` | integer | `26` |
| `ui.sidebar_min_width` | integer | `18` |
| `ui.sidebar_max_width` | integer | `36` |
| `ui.sidebar_start_collapsed` | boolean | `false` |
| `ui.sidebar_collapsed_mode` | `compact`, `hidden` | `compact` |
| `ui.mobile_width_threshold` | integer | `64` |
| `ui.mouse_capture` | boolean | `true` |
| `ui.copy_on_select` | boolean | `true` |
| `ui.host_cursor` | `auto`, `native`, `drawn` | `auto` |
| `ui.right_click_passthrough_modifier` | string | `""` |
| `ui.redraw_on_focus_gained` | boolean | `true` |
| `ui.mouse_scroll_lines` | integer | `3` |
| `ui.confirm_close` | boolean | `true` |
| `ui.prompt_new_tab_name` | boolean | `true` |
| `ui.prompt_new_workspace_name` | boolean | `false` |
| `ui.pane_borders` | `auto`, `always`, `off`; legacy boolean accepted | `"auto"` |
| `ui.pane_outer_borders` | boolean | `true` |
| `ui.pane_scrollbars` | boolean | `true` |
| `ui.pane_gaps` | boolean | `true` |
| `ui.show_agent_labels_on_pane_borders` | boolean | `false` |
| `ui.hide_tab_bar_when_single_tab` | boolean | `false` |
| `ui.tab_bar_position` | `top`, `bottom` | `"top"` |
| `ui.tab_bar_right` | `zoom`, `hostname`, `datetime`, `text`, `command` | `[]` |
| `ui.tab_bar_right_separator` | string | `" "` |
| `ui.window_title` | string | `"{hostname}: {workspace}"` |
| `ui.agent_panel_sort` | `spaces`, `priority` | `"spaces"` |
| `ui.status_indicators` | `dots`, `symbols` | `"dots"` |
| `ui.sidebar.agents.row_gap` | integer | `0` |
| `ui.sidebar.agents.rows` | list of token rows | `[["state_icon", "machine", "workspace", "tab"], ["agent"]]` |
| `ui.sidebar.agents.rows_by_agent` | table of token rows | `{}` |
| `ui.sidebar.spaces.row_gap` | integer | `0` |
| `ui.sidebar.spaces.rows` | list of token rows | `[["state_icon", "workspace"], ["branch", "git_status"]]` |
| `ui.accent` | color | `"cyan"` |

## Notifications

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `ui.toast.delivery` | `off`, `herdr`, `terminal`, `system` | `"off"` |
| `ui.toast.delay_seconds` | integer | `1` |
| `ui.toast.herdr.position` | `top-left`, `top-right`, `bottom-left`, `bottom-right` | `"bottom-right"` |
| `ui.toast.clipboard.enabled` | boolean | `true` |
| `ui.toast.clipboard.position` | `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right` | `"bottom-center"` |

## Sound

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `ui.sound.enabled` | boolean | `true` |
| `ui.sound.path` | path | `unset` |
| `ui.sound.done_path` | path | `unset` |
| `ui.sound.request_path` | path | `unset` |
| `ui.sound.agents.pi` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.claude` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.codex` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.gemini` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.cursor` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.devin` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.agy` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.cline` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.open_code` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.github_copilot` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.kimi` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.kiro` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.droid` | `default`, `on`, `off` | `"off"` |
| `ui.sound.agents.amp` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.grok` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.hermes` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.kilo` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.qodercli` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.qwen` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.maki` | `default`, `on`, `off` | `"default"` |
| `ui.sound.agents.muse` | `default`, `on`, `off` | `"default"` |

## Session

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `session.resume_agents_on_restore` | boolean | `true` |

## Worktrees

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `worktrees.directory` | string | `"~/.herdr/worktrees"` |

## Remote

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `remote.manage_ssh_config` | boolean | `true` |

## Advanced

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `advanced.scrollback_limit_bytes` | integer | `10000000` |

## Experimental

| Setting | Type / values | Upstream default |
| --- | --- | --- |
| `experimental.allow_nested` | boolean | `false` |
| `experimental.kitty_graphics` | boolean | `unset` |
| `experimental.pane_history` | boolean | `false` |
| `experimental.reveal_hidden_cursor_for_cjk_ime` | boolean | `false` |
| `experimental.cjk_ime_agents` | list of strings | `[]` |
| `experimental.cjk_ime_cursor_shape` | `block`, `steady_block`, `underline`, `steady_underline`, `bar`, `steady_bar` | `"steady_block"` |
| `experimental.switch_ascii_input_source_in_prefix` | boolean | `false` |

## Compound settings

`keys.command` is a list of records with `key`, `command`, `type`, `description`, `width`, and `height`.
`key` accepts a string or a list of strings. `type` accepts `shell`, `pane`, `popup`, or `plugin_action`.
Popup dimensions accept positive cell counts or percentage strings.

`ui.tab_bar_right` accepts `zoom`, `hostname`, `datetime`, `text`, and `command` entries.
Use `format` for datetime, `text` for literal text, and `command`, `interval_seconds`, and `timeout_seconds` for commands.

Sidebar tokens accept a string or a record with `token`, `fg`, `bold`, `dim`, and `rules`.
Each rule has one condition (`equals`, `contains`, `starts_with`, `gt`, or `lt`) and optional style fields.
Text conditions also accept `ignore_case`. Row lists, rows, and rule lists are limited to 16 entries.

The module also declares legacy `keys.fullscreen`, `advanced.scrollback_lines`, `ui.toast.enabled`, and `ui.agent_panel_scope`.
The first two are aliases; `scrollback_lines` still measures bytes. `ui.agent_panel_scope` has no effect.

Full descriptions are available in Home Manager's generated option manual and the [upstream configuration guide](https://herdr.dev/docs/configuration/).
