# herdr-nix

Always up-to-date Nix package for [herdr](https://github.com/ogulcancelik/herdr), an agent multiplexer that lives in your terminal.

## Quick Start

```bash
nix run github:kevinpita/herdr-nix
```

## Install

```bash
nix profile install github:kevinpita/herdr-nix
```

## Use In A Flake

```nix
{
  inputs.herdr-nix.url = "github:kevinpita/herdr-nix";

  outputs = { herdr-nix, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          herdr-nix.packages.${system}.default
        ];
      };
    };
}
```

## Development

```bash
nix build .#herdr
./result/bin/herdr --version
```

## Updates

The update workflow checks upstream releases hourly and can also be run manually from GitHub Actions. When a new release exists, it updates `package.nix`, refreshes the fixed-output hashes, creates a pull request, and enables auto-merge.

Manual update:

```bash
./scripts/update.sh --check
./scripts/update.sh --version 0.5.6
```
