{
  pkgs,
  ...
}:

# Built by CI, not by consumers: the resulting binary is published as the
# release asset that package.nix fetches.
let
  data = builtins.fromJSON (builtins.readFile ./version.json);
in
pkgs.lazygit.overrideAttrs (old: {
  version = data.version;

  src = pkgs.fetchFromGitHub {
    owner = "jesseduffield";
    repo = "lazygit";
    tag = "v${data.version}";
    hash = data.srcHash;
  };

  # nixpkgs pins this in the derivation, so it has to be restated for the
  # overridden version.
  ldflags = [
    "-X main.version=${data.version}"
    "-X main.buildSource=nix"
  ];

  patches = [ ./remove-donate-links.patch ];
})
