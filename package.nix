{
  lib,
  stdenv,
  fetchurl,
}:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
  system = stdenv.hostPlatform.system;

  asset =
    {
      x86_64-linux = "lazygit-linux-x86_64";
      aarch64-linux = "lazygit-linux-aarch64";
    }
    .${system} or (throw "lazygit: unsupported system ${system}");
in
stdenv.mkDerivation {
  pname = "lazygit";
  version = data.version;

  src = fetchurl {
    url = "https://github.com/atomic-235/lazygit-flake/releases/download/v${data.version}/${asset}";
    hash = data.assets.${system};

    # The binary embeds paths for tzdata, mailcap and iana-etc. They are
    # runtime lookups with built-in fallbacks, not hard dependencies, but Nix
    # refuses fixed-output paths that reference the store.
    unsafeDiscardReferences = true;
  };

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/lazygit"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple terminal UI for git commands, without donate links (static release binary)";
    homepage = "https://github.com/jesseduffield/lazygit";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "lazygit";
  };
}
