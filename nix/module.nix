{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.go-nix;
in
{
  options.services.go-nix = {
    enable = lib.mkEnableOption "go nix example service";
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = ":8081";
      description = "Address and port to expose api";
    };
    configFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of files to include, use for secrets";
    };
  };

  config = lib.mkIf cfg.enable
    {
      systemd.services.go-nix = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Restart = "always";
            DynamicUser = true;
            MemoryDenyWriteExecute = true;
            PrivateDevices = true;
            ProtectSystem = "strict";
            RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX"];
            RestrictNamespaces = true;
            RestrictSUIDSGID = true;
            ExecStart = ''
              ${pkgs.goNix}/bin/go-nix -l ${cfg.listenAddress}
            '';
            User="gonix";
            RuntimeDirectory="gonix";
          };
        };
    };
}
