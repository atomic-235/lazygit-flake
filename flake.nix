{
  description = "lazygit without donate/ask-question links, built static and published as a release binary";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          default = pkgs.callPackage ./package.nix { };
          static = pkgs.callPackage ./static.nix { };
          lazygit = default;
        }
      );

      overlays.default = final: _prev: {
        lazygit = final.callPackage ./package.nix { };
      };
    };
}
