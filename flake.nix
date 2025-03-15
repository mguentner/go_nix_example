{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      # from https://github.com/NixOS/templates/blob/master/go-hello/flake.nix
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [
          self.overlay
          (final: prev: { goNixVersion = version; })
        ];
      });
    in
    {
      overlay = import ./nix/overlay.nix;
      packages = forAllSystems
        (system:
          {
            inherit (nixpkgsFor.${system}) goNix;
          });
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            name = "default";
            buildInputs = with pkgs; [
              go
              gopls
              bashInteractive
            ];
            env = {
            };
          };
        });

      checks = forAllSystems (system: {
        nixos-test = nixpkgsFor.${system}.callPackage ./nix/nixos-test.nix {};
      });
    };
}
