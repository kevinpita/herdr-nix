{
  onboarding = false;
  server = {
    headless_cols = 160;
    headless_rows = 50;
  };
  terminal = {
    shell_mode = "non_login";
    new_cwd = "~/Projects";
    kitty_graphics = true;
  };
  theme = {
    name = "catppuccin";
    auto_switch = true;
    light_name = "catppuccin-latte";
    dark_name = "catppuccin";
    custom = {
      accent = "#89b4fa";
      light = {
        panel_bg = "#eff1f5";
        text = "#4c4f69";
      };
      dark = {
        panel_bg = "#1e1e2e";
        text = "#cdd6f4";
      };
    };
  };
  keys = {
    prefix = "ctrl+a";
    next_tab = [
      "prefix+n"
      "ctrl+alt+right"
    ];
    move_tab_previous = "prefix+alt+left";
    move_tab_next = "prefix+alt+right";
    resize_pane_left = "ctrl+shift+alt+left";
    resize_pane_right = "ctrl+shift+alt+right";
    command = [
      {
        key = "prefix+alt+g";
        type = "popup";
        command = "lazygit";
        description = "Open Git UI";
        width = "80%";
        height = 30;
      }
      {
        key = "prefix+alt+c";
        type = "shell";
        command = "printf ready";
        description = "Run a background command";
      }
    ];
  };
  ui = {
    pane_borders = "always";
    pane_outer_borders = true;
    pane_scrollbars = true;
    tab_bar_position = "bottom";
    status_indicators = "symbols";
    window_title = "{hostname}: {workspace}";
    tab_bar_right = [
      { type = "zoom"; }
      { type = "hostname"; }
      {
        type = "datetime";
        format = "%H:%M";
      }
      {
        type = "text";
        text = "Nix";
      }
      {
        type = "command";
        command = "printf ready";
        interval_seconds = 5;
        timeout_seconds = 2;
      }
    ];
    tab_bar_right_separator = " · ";
    sidebar = {
      agents = {
        row_gap = 0;
        rows = [
          [
            "state_icon"
            "machine"
            "workspace"
            "tab"
          ]
          [
            {
              token = "agent";
              bold = true;
            }
          ]
          [
            {
              token = "$load";
              fg = "#fff";
              rules = [
                {
                  gt = 80;
                  fg = "#f55";
                  bold = true;
                }
                {
                  gt = 50;
                  fg = "#fc0";
                }
              ];
            }
          ]
          [
            {
              token = "machine";
              rules = [
                {
                  equals = "Local";
                  ignore_case = true;
                  dim = true;
                }
              ];
            }
          ]
        ];
        rows_by_agent.claude = [
          [
            "state_icon"
            "agent"
          ]
          [ "terminal_title_stripped" ]
        ];
      };
      spaces = {
        row_gap = 0;
        rows = [
          [
            "state_icon"
            "workspace"
          ]
          [
            "branch"
            "git_status"
          ]
        ];
      };
    };
    toast = {
      delivery = "herdr";
      delay_seconds = 1;
      herdr.position = "bottom-right";
      clipboard = {
        enabled = true;
        position = "bottom-center";
      };
    };
    sound = {
      enabled = false;
      agents = {
        claude = "on";
        droid = "off";
        muse = "default";
      };
    };
  };
  session.resume_agents_on_restore = true;
  worktrees.directory = "~/.herdr/worktrees";
  remote.manage_ssh_config = true;
  advanced.scrollback_limit_bytes = 10000000;
  experimental = {
    allow_nested = false;
    pane_history = false;
    reveal_hidden_cursor_for_cjk_ime = false;
    cjk_ime_agents = [
      "claude"
      "pi"
      "codex"
    ];
    cjk_ime_cursor_shape = "steady_block";
    switch_ascii_input_source_in_prefix = false;
  };
  update = {
    version_check = false;
    manifest_check = false;
    channel = "stable";
  };
}
