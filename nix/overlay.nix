final: prev: {
  # default value, this will be overwritten by the flake
  goNixVersion = "0.1";
  goNix = with final; final.callPackage ./package.nix { version=goNixVersion; };
}
