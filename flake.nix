{
  description = "Nix flake for herdr, an agent multiplexer that lives in your terminal";

  nixConfig = {
    extra-substituters = [ "https://kevinpita.cachix.org" ];
    extra-trusted-public-keys = [ "kevinpita.cachix.org-1:Cu9UtCDSfDq3/WDnI7N1N/LzAh90SPS+1R+nWao/hz0=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        herdr = final.callPackage ./package.nix { };
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        {
          packages = {
            default = pkgs.herdr;
            herdr = pkgs.herdr;
          };

          apps = {
            default = {
              type = "app";
              program = "${pkgs.herdr}/bin/herdr";
            };
            herdr = {
              type = "app";
              program = "${pkgs.herdr}/bin/herdr";
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              gh
              jq
              nixpkgs-fmt
            ];
          };
        }) // {
      overlays.default = overlay;
    };
}
