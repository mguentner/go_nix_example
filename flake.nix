{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nix-github-actions, nixpkgs }:
    let
      # from https://github.com/NixOS/templates/blob/master/go-hello/flake.nix
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          (final: prev: { goNixVersion = version; })
        ];
      });
    in
    {
      overlays.default = import ./nix/overlay.nix;
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
            env = { };
          };
        });

      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks = nixpkgs.lib.getAttrs [ "x86_64-linux" ] self.checks;
      };

      checks = forAllSystems (system: {
        nixos-test = nixpkgsFor.${system}.callPackage ./nix/nixos-test.nix { };
      });
    };
}
