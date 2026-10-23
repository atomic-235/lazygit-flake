{
  lib,
  stdenv,
  curl,
  cacert,
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

  url = "https://github.com/atomic-235/lazygit-flake/releases/download/v${data.version}/${asset}";

  # Fixed-output fetch at build time. The Go binary embeds paths for tzdata,
  # mailcap and iana-etc (runtime lookups with built-in fallbacks), which makes
  # Nix's reference check reject it unless the check is waived.
  binary = stdenv.mkDerivation {
    name = "lazygit-${data.version}-${asset}";

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = data.assets.${system};
    unsafeDiscardReferences = true;

    nativeBuildInputs = [ curl ];

    buildCommand = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      curl -fsSL --cacert "$SSL_CERT_FILE" -o "$out" ${lib.escapeShellArg url}
    '';
  };
in
stdenv.mkDerivation {
  pname = "lazygit";
  version = data.version;

  src = binary;
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
