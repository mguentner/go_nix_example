{ nixosTest, pkgs }:

nixosTest {
  name = "go-nix";

  nodes.server = { ... }: {
    imports = [ ./module.nix ];
    services.go-nix =
    {
      enable = true;
      listenAddress = ":1337";
    };
  };

  testScript = ''
    start_all()
    server.wait_for_unit("go-nix.service")
    server.wait_until_succeeds("${pkgs.curl}/bin/curl http://127.0.0.1:1337")
  '';
}
