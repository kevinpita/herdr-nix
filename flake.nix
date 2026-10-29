{
  description = "Nix flake for herdr: the desktop app, herdr-core (hc), and the herdr TUI";

  nixConfig = {
    extra-substituters = [ "https://kevinpita.cachix.org" ];
    extra-trusted-public-keys = [
      "kevinpita.cachix.org-1:Cu9UtCDSfDq3/WDnI7N1N/LzAh90SPS+1R+nWao/hz0="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      overlay = final: _prev: {
        herdr = final.callPackage ./packages/herdr-app.nix { };
        # Static on Linux: `hc machine add` copies this binary to other machines.
        herdr-core =
          (if final.stdenv.hostPlatform.isLinux then final.pkgsStatic else final).callPackage
            ./packages/herdr-core.nix
            { };
        herdr-tui = final.callPackage ./packages/herdr-tui.nix { };
      };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          default = pkgs.herdr;
          inherit (pkgs) herdr herdr-core herdr-tui;
        };

        formatter = pkgs.nixfmt-tree;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gh
            jq
            nixfmt
            python3
          ];
        };
      }
    )
    // {
      overlays.default = overlay;
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeModules.default = import ./modules/home-manager.nix;
      nixosModules.default = import ./modules/nixos.nix;
    };
}
