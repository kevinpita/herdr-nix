# herdr-nix

Nix package, Home Manager module, and NixOS module for [Herdr](https://github.com/herdrdev/herdr) **0.9.0**.

Flake systems: `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`. The pinned nixpkgs no longer supports `x86_64-darwin`.

Configure all 207 settings in the upstream reference, custom keybindings, plugins, saved SSH machines, and agent integrations with Nix. Builds check the generated configuration with `herdr config check`.

## Home Manager

Add the input and module to your flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr-nix = {
      url = "github:kevinpita/herdr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, herdr-nix, ... }: {
    homeConfigurations.alice = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        herdr-nix.homeModules.default
        ({ pkgs, ... }: {
          home = {
            username = "alice";
            homeDirectory = "/home/alice";
            stateVersion = "26.05";
          };
          programs.herdr = {
            enable = true;
            settings = {
              theme.name = "catppuccin";
              keys.prefix = "ctrl+a";
              terminal.default_shell = "${pkgs.fish}/bin/fish";
              ui.pane_borders = "always";
              ui.toast.delivery = "herdr";
            };
            extraPackages = with pkgs; [ git openssh lazygit ];
          };
        })
      ];
    };
  };
}
```

Replace the username, home directory, and system with your values. Keep an existing `home.stateVersion` unchanged. Then run:

```sh
home-manager switch --flake .#alice
herdr
```

No overlay is required. The module uses this repository's package unless you set `programs.herdr.package`.

## Plugins

Add a built plugin directory. Nix can fetch the source, or you can keep it beside your configuration:

```nix
programs.herdr = {
  enable = true;
  plugins.layout = {
    source = ./plugins/layout; # contains herdr-plugin.toml
    configFiles."config.toml".text = ''
      workspace = "development"
    '';
  };
  settings.keys.command = [ {
    key = "prefix+alt+l";
    type = "plugin_action";
    command = "example.layout.apply";
    description = "Apply layout";
  } ];
};
```

The plugin defines its configuration format and action IDs. `plugins.layout` is only a Nix label. See [plugin sources, builds, files, and ownership](docs/modules.md#plugins).

## NixOS

Add `herdr-nix.nixosModules.default` to the `modules` list of your `nixpkgs.lib.nixosSystem` call. Then configure:

```nix
programs.herdr = {
  enable = true;
  settings = {
    theme.name = "nord";
    ui.toast.delivery = "terminal";
  };
};
```

The module installs Herdr and writes `/etc/herdr/config.toml`. A wrapper uses this file only when no user configuration or `HERDR_CONFIG_PATH` override exists. It does not redirect user state to `/etc`.

Use Home Manager for per-user plugins, machines, and integrations. With Home Manager's NixOS module already imported:

```nix
home-manager.sharedModules = [ herdr-nix.homeModules.default ];
home-manager.users.alice.programs.herdr = {
  enable = true;
  machines.builder = { target = "build-host"; session = "work"; };
  plugins.layout = ./plugins/layout;
};
```

System and user settings are **not merged**. A user config replaces the system fallback. See [module reference](docs/modules.md).

## Configuration reference

- [Module options and file ownership](docs/modules.md)
- [All 0.9 settings and defaults](docs/settings.md)
- [Advanced settings example](examples/settings.nix): light/dark themes, sidebar rules, tab status, popups, notifications, and graphics
- [Design and upstream Nix examples](docs/design.md)

Settings use upstream names, such as `settings.ui.pane_borders`, not a second set of camel-case aliases. Unset values keep Herdr defaults. The module sets only `onboarding = false` and `update.version_check = false` by default.

**Do not put secrets in Nix settings or file contents.** Nix store files are readable by all users. Keep tokens, SSH keys, and plugin credentials in separate runtime files.

## Package only

The existing package, app, and overlay outputs remain available:

```sh
nix run github:kevinpita/herdr-nix
nix profile install github:kevinpita/herdr-nix
```

Use `herdr-nix.packages.${system}.default` in a shell or package list. Use `herdr-nix.overlays.default` to add `pkgs.herdr`.

The package includes Bash, Fish, and Zsh completions, the default config, the bundled agent skill, and integration assets under `share/herdr`.

## Binary cache

The flake advertises `https://kevinpita.cachix.org`. Existing `x86_64-linux` package builds can be downloaded from this cache. New module outputs or uncached package revisions can require local builds.

To configure the cache permanently:

```sh
cachix use kevinpita
```

## Development

Run these commands from the repository root:

```sh
nix develop
nix fmt
nix flake check --all-systems --no-build
nix build .#herdr
./result/bin/herdr --version
```

For new, untracked files, use `nix flake check "path:$PWD" --all-systems --no-build` until the files are added to Git.

Configuration builds use Herdr's own validation commands. Plugin registration uses an isolated build home and does not run plugin code.

## Updates

The update workflow checks releases hourly. It checks configuration metadata and evaluates the flake before it creates a pull request.

```sh
./scripts/update.sh --check
./scripts/update.sh --version 0.9.0
```

When upstream configuration changes, review the new contract, then run:

```sh
./scripts/update-config-reference.sh
python3 scripts/render-settings.py
nix flake check "path:$PWD" --all-systems --no-build
```

A changed schema can also require changes to `modules/settings.nix` and examples. The update script stops if upstream metadata differs from the checked-in copy.
