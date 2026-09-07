# Module reference

Import `homeModules.default` for Home Manager or `nixosModules.default` for NixOS. `homeManagerModules.default` is an alias for `homeModules.default`. You can also import `modules/home-manager.nix` or `modules/nixos.nix` without flakes.

The Home Manager module disables Home Manager's built-in `programs/herdr.nix` module. Do not import a second third-party Herdr module at the same time.

## Shared options

All options are under `programs.herdr`.

| Option | Default | Effect |
| --- | --- | --- |
| `enable` | `false` | Install and configure Herdr. |
| `package` | This repository's package | Choose the Herdr binary. No overlay is required. |
| `settings` | See below | Generate typed TOML configuration. |
| `validateConfig` | `true` | Fail the build if `herdr config check` reports an issue. |
| `extraPackages` | `[]` | Add tools to the Herdr wrapper's `PATH`. |
| `extraFiles` | `{}` | Add config-relative files. |
| `configFile` | Read-only output | Generated TOML store path. |
| `finalPackage` | Read-only output | Package with the module's runtime environment. |

Enabling the module sets `settings.onboarding = false` and `settings.update.version_check = false` with `mkDefault`. You can override either value. Other settings default to `null` and are omitted from TOML. Empty keybinding lists and explicit `false` values are preserved.

Known settings have Nix types. The setting names match Herdr's TOML keys. Tables also accept additional TOML fields, so a newer package does not require an immediate module release. The package's config checker remains the final check for unknown keys, colors, key chords, sidebar conditions, and required fields. Use a binary that supports the setting. Disabling validation does not add support to an older binary.

Prefer `settings` to raw TOML text. There is no `extraConfig` string: TOML cannot safely append duplicate tables or redefine values. Nix module merging provides `mkDefault`, `mkForce`, `mkBefore`, and `mkAfter` instead.

The generated configuration is read-only. Change Nix settings rather than the Settings UI, `config reset-keys`, or `channel set`. After activation, run `herdr server reload-config` for each running session, or use the UI reload action to reload both client and server settings. Startup-only settings require a restart or client reattach. Activation does not stop running panes.

### Files

Home Manager writes files below `$XDG_CONFIG_HOME/herdr`. NixOS writes them below `/etc/herdr`.

```nix
programs.herdr.extraFiles = {
  "sounds/done.mp3" = ./sounds/done.mp3;
  "scripts/status.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      printf 'ready\n'
    '';
  };
};
programs.herdr.settings.ui.sound.done_path = "sounds/done.mp3";
```

A value can be a file path or `{ source = path; }` or `{ text = "..."; }`. Set exactly one of `source` and `text`. For text files, `executable = true` adds execute permission. For source files in Home Manager, preserve the source file's execute permission.

Names must be relative paths without `.` or `..` components. You cannot replace `config.toml`. Home Manager also reserves plugin paths. For status commands, prefer an absolute Nix store executable over a relative command path. Relative sound paths resolve beside `config.toml`. The build checker stages `extraFiles` beside the validation config so these paths can be checked. If a sound file exists only at runtime, set `validateConfig = false` and run `herdr config check` after activation.

### Runtime tools

Use `extraPackages` for commands that Herdr or a plugin runs: `git`, `openssh`, language runtimes, clipboard tools, notification tools, or popup programs. For example:

```nix
programs.herdr.extraPackages = with pkgs; [ git openssh nodejs wl-clipboard libnotify lazygit ];
```

A login shell can change `PATH`. Use absolute store paths in commands when exact command selection matters. The module does not choose an agent package or enable a desktop notification service for you.

### Environment variables

Use the existing Nix environment options for Herdr's environment-only controls:

```nix
# Home Manager
home.sessionVariables = {
  HERDR_LOG = "herdr=info";
  HERDR_PROCESS_DETECTION = "native";
  HERDR_DISABLE_SOUND = "1";
};
```

On NixOS, use `environment.sessionVariables` instead. `HERDR_SESSION` selects a named session, and `HERDR_SOCKET_PATH` overrides the control socket. Set `HERDR_CONFIG_PATH` only when you intend to bypass the module's normal config file. Environment variables are not secrets storage. A systemd user service has its own environment; add overrides through `systemd.user.services.herdr.Service.Environment` in Home Manager.

## Home Manager options

| Option | Default | Effect |
| --- | --- | --- |
| `plugins` | `null` | Manage the full plugin registry. |
| `machines` | `null` | Manage the saved SSH machine catalog. |
| `integrations` | `[]` | Run selected upstream integration installers at activation. |
| `skillDirectories` | `[]` | Link the bundled skill into home-relative directories. |
| `server.enable` | `false` | Run a headless server as a systemd user service on Linux. |
| `server.session` | `"default"` | Select the service's Herdr session. |

### Plugins

`plugins` is an attribute set. Values can be plugin directories or records:

```nix
programs.herdr.plugins = {
  local = ./plugins/local;
  tools = {
    source = myBuiltPlugin;
    enable = false;
    configFiles = {
      "config.toml".text = ''
        workspace = "work"
      '';
      "preferences.json" = (pkgs.formats.json {}).generate "preferences.json" {
        showStatus = true;
      };
    };
  };
};
```

`source` must contain `herdr-plugin.toml`. A package output or a subdirectory of a fetched repository also works:

```nix
let
  pluginSource = pkgs.fetchFromGitHub {
    owner = "YOUR-OWNER";
    repo = "YOUR-PLUGIN-REPO";
    rev = "YOUR-COMMIT";
    hash = "sha256-YOUR-HASH";
  };
in {
  programs.herdr.plugins.layout = "${pluginSource}/layout";
}
```

Replace the four source values with the plugin's pinned values. You can also use a flake input with `flake = false`; its revision is recorded in `flake.lock`.

If a plugin needs a build, create a normal Nix derivation. For example, use `buildNpmPackage` for a Node plugin or `rustPlatform.buildRustPackage` for a Rust plugin. Install the manifest, executable, and required data into the output. Put build dependencies in the derivation and runtime dependencies in `extraPackages`, or use absolute executable paths in the manifest.

The module runs `herdr plugin link` in an isolated build home. It does **not** run manifest build commands, fetch unpinned sources at activation, or execute plugins during registration. Herdr validates the manifest and creates the registry. Startup hooks, actions, event hooks, panes, link handlers, platform restrictions, minimum versions, and disabled state retain upstream behavior.

Plugin IDs come from the manifests. Duplicate IDs fail the build. Nix attribute names are only labels. Herdr also computes each plugin's config directory name, including escaped IDs; the module does not reimplement this encoding.

`configFiles` writes individual files, not an immutable plugin state directory. Other files in the plugin config directory remain writable. Plugin runtime state stays under `$XDG_STATE_HOME/herdr/plugins`. Plugin code has your user permissions and is not sandboxed at runtime. Use only trusted plugins. Source directories in the Nix store are read-only; plugins must write to `HERDR_PLUGIN_STATE_DIR` or `HERDR_PLUGIN_CONFIG_DIR`, not their source directory.

#### Registry ownership

- `plugins = null` leaves the registry unmanaged. Use the CLI to install plugins.
- `plugins = {}` manages an empty registry.
- A nonempty set manages exactly those plugins, including disabled entries.

Do not use CLI install, unlink, enable, or disable commands on a Nix-owned registry. Upstream can atomically replace its symlink. This creates a conflicting file which can block the next Home Manager activation. Keep a backup before changing ownership, and use Home Manager's normal conflict-resolution procedure. The module never forces replacement of an existing user file.

Restart the affected server after changing startup hooks. Linking a plugin or reloading configuration does not run its startup hook.

### SSH machines

```nix
programs.herdr.machines = {
  builder = {
    label = "Build machine";
    target = "builder";
    session = "work";
    enabled = true;
  };
  archive = {
    target = "user@archive.example.org";
    enabled = false;
  };
};
```

Use your OpenSSH configuration for aliases, ports, keys, and authentication. Machine records contain only `id`, `label`, `target`, `session`, and `enabled`. Password-bearing targets fail validation. These records are stored in the Nix store, so keep sensitive host information outside this option if necessary.

Each entry gets a stable 32-character ID from its Nix attribute name. Changing the label does not change the ID; renaming the attribute does. Set `id` explicitly to retain an existing ID from `herdr machine list --json`.

The module writes `$XDG_STATE_HOME/herdr/client/endpoints.json`. The separate `endpoint-selection.json` file stays writable. `null` leaves the catalog unmanaged; `{}` manages an empty catalog. As with plugins, do not mix CLI edits with a Nix-owned catalog.

Before using a saved machine, install a compatible Herdr on it and prepare its SSH connection. Activation never runs `herdr machine add`, installs remote software, or opens SSH connections. Opening the Herdr client can connect to enabled machines.

### Agent integrations and skills

```nix
programs.herdr = {
  integrations = [ "pi" "claude" "codex" ];
  skillDirectories = [ ".agents/skills/herdr" ".claude/skills/herdr" ];
};
```

Supported integration targets are `pi`, `omp`, `claude`, `codex`, `copilot`, `devin`, `droid`, `kimi`, `opencode`, `kilo`, `hermes`, `qodercli`, `qwen`, `cursor`, `mastracode`, `antigravity-cli`, and `grok`.

Integrations use the **upstream installers**, not declarative ownership of other agents' settings. This is an explicit opt-in to modify those agents' writable config files. Install and initialize each agent first. Installation runs after Home Manager links its files. It respects activation dry-run mode. It can fail if the target configuration is already a read-only Nix file. In that case, leave `integrations` empty and configure the agent's own module with the packaged assets under `share/herdr/integrations`.

Removing an integration from the list does not uninstall existing hooks. Remove them explicitly with `herdr integration uninstall TARGET`. The module does not install the agent itself. Agent detection that needs no integration remains built into Herdr.

`skillDirectories` is declarative. Each path points to the same bundled skill directory. Removing a path removes its Home Manager link.

### Headless service

```nix
programs.herdr.server = {
  enable = true;
  session = "work";
};
```

This creates `herdr.service` in the systemd user manager. It runs `herdr --session work server`. Attach with `herdr --session work`. Stop a manually started server for that session before enabling the service.

The service starts with the user manager, not as root. Configure user lingering separately if the service must run without a login. Stopping the service ends its pane processes. The module does not enable lingering or stop a running manual server during activation.

On macOS, keep `server.enable = false` and let Herdr start its normal background server when you open the app.

## NixOS file selection

The NixOS wrapper chooses:

1. An explicit `HERDR_CONFIG_PATH`, including a deliberately empty value.
2. The user's `$XDG_CONFIG_HOME/herdr/config.toml`, or `~/.config/herdr/config.toml`.
3. `/etc/herdr/config.toml` as a fallback.

Herdr does not merge these files. This wrapper is necessary because upstream 0.9 reads no system-wide config by default. It does not change `XDG_CONFIG_HOME`, plugin paths, or state paths. Per-user features belong in the Home Manager module, including when Home Manager runs from NixOS.

## Limits

The modules configure Herdr; they do not declare live workspaces, running agents, pane contents, session snapshots, or arbitrary remote machines' server state. Use plugin startup hooks or Herdr's CLI/API for live orchestration. Pane history can contain sensitive terminal content; `settings.experimental.pane_history` remains off unless you enable it.

Native config, plugin, machine, and integration checks execute the chosen binary. `validateConfig = false` skips only the TOML check. It does not enable cross-compilation of plugin registries or machine catalogs.
