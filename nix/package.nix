{ buildGoModule
, version
, lib
}:
buildGoModule {
  pname = "go-nix";
  inherit version;

  src = builtins.filterSource (path: type: !(lib.strings.hasSuffix "nix" path || lib.strings.hasSuffix "flake.lock" path)) ( lib.cleanSource ../.);

  vendorHash = null;
  buildInputs = [];

  doCheck = false;

  postInstall = ''
    mv $out/bin/go_nix_example $out/bin/go-nix
  '';
}