# lazygit-flake

lazygit with `remove-donate-links.patch`, built static and published as a single
release binary.

Go static builds still embed the tzdata/mailcap/iana-etc paths, which `fetchurl`
rejects — and it does not accept `unsafeDiscardReferences`. `package.nix`
therefore fetches the asset with a flat fixed-output `stdenv.mkDerivation` and
`unsafeDiscardReferences = true`.

## Packages

| Attribute | Contents |
|---|---|
| `packages.<system>.default` | the published static binary |
| `packages.<system>.lazygit` | alias of `default` |
| `packages.<system>.static` | the patched `pkgsStatic.lazygit` build |

`overlays.default` provides `pkgs.lazygit`.

## Usage

```nix
{
  inputs.lazygit-flake.url = "github:atomic-235/lazygit-flake";
  inputs.lazygit-flake.inputs.nixpkgs.follows = "nixpkgs";
}
```

```nix
nixpkgs.overlays = [ inputs.lazygit-flake.overlays.default ];
# pkgs.lazygit
```

## Updates

CI runs weekly (Monday 06:00 UTC): resolve the newest nixpkgs `lazygit`
version, build the static binary (restating `ldflags`, since `overrideAttrs`
with a new version does not rewrite them and lazygit embeds its version that
way), upload `lazygit-linux-x86_64`, verify, commit and tag `v<version>`.

Supported: `x86_64-linux`, `aarch64-linux`.
