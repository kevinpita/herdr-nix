# Module design

## Caller contract

```nix
programs.herdr = {
  enable = true;
  settings.ui.pane_borders = "always";
  plugins.layout = ./plugins/layout; # Home Manager
};
```

The package-only outputs remain available. Home Manager owns user files. NixOS owns the package and `/etc/herdr` fallback files.

## Data and ownership

- `settings` is a nested Nix attribute set with upstream TOML names.
- `data/config-reference.json` is the option metadata from the pinned Herdr source.
- `modules/settings.nix` maps that metadata to Nix types and adds compound types for commands, sidebar tokens, rules, and status entries.
- `lib/config.nix` removes unset values, generates TOML, and checks it with the selected Herdr binary.
- Plugin inputs are an attribute set of built source directories, enabled flags, and files. Herdr creates the installed registry at build time.
- Machine inputs are an attribute set of saved SSH profiles. Herdr validates the generated catalog without making a connection.
- The Home Manager module links individual config files. It does not replace runtime state directories.

The update script compares the metadata with the pinned source. A changed reference requires a maintainer to review the option model before the update can continue.

## Alternatives

A raw `settings` TOML attribute set is small and matches many Home Manager modules. However, it gives no Nix type errors or option help for the user's request to expose all settings.

A second hand-written API, such as `themeName` and `paneBorders`, gives simple top-level controls but duplicates Herdr's naming and defaults. It also requires users to learn two configuration formats.

The selected design uses typed settings with the original names. It keeps a freeform TOML extension for new fields, while Herdr's checker validates semantics. Null defaults avoid writing every upstream default into the file. This matters for keybindings because Herdr tracks which fields the user set explicitly.

The metadata-driven approach must be reconsidered if upstream removes its machine-readable config reference. The registry builder must be reconsidered if Herdr no longer supports offline `plugin link`.

## Upstream Nix examples checked

These sources informed the module, rather than a new configuration framework:

- [Home Manager Herdr](https://github.com/nix-community/home-manager/blob/2c0350c759688177331b8f5242311fae8877bdb3/modules/programs/herdr.nix): `programs.herdr`, TOML generation, and XDG config placement. This repository replaces that basic module when imported.
- [Home Manager Yazi](https://github.com/nix-community/home-manager/blob/2c0350c759688177331b8f5242311fae8877bdb3/modules/programs/yazi.nix): plugin paths or records, runtime packages, and generated config files.
- [Home Manager Zellij](https://github.com/nix-community/home-manager/blob/2c0350c759688177331b8f5242311fae8877bdb3/modules/programs/zellij.nix): `finalPackage`, plugin dependencies, and separate user files.
- [nixpkgs tmux](https://github.com/NixOS/nixpkgs/blob/42f17a57f4f6e33b3de3dca0a2a5ea5233169d02/nixos/modules/programs/tmux.nix): `programs` module structure, package overrides, plugins, and system configuration.

Herdr differs from tmux: it does not read `/etc/herdr/config.toml` itself. The NixOS wrapper supplies that path only when the user has no override. System and user settings are not merged.

## Build-time validation

The modules use `herdr config check`, offline `herdr plugin link`, and `herdr machine list` to validate generated artifacts. The commands run in temporary build homes. They do not activate a Home Manager generation or connect to SSH hosts.

`nix flake check --all-systems --no-build` checks flake output evaluation. It does not prove live terminal behavior.
