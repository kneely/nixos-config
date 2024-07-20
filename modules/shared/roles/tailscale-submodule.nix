{ options, config, lib, pkgs, inputs, secrets, ... }:

with lib;
let
  ### Set container name and image
  NAME = "tailscale";
  IMAGE = "ghcr.io/tailscale/tailscale";

  inherit (config.networking) hostName;
  tailnetName = "tail103fe.ts.net";
  dockerDataDir = "/storage/docker";

  containerOpts = { name, config, ... }: 
    let
      # this allows container modules to name their TS submodule "TS${containerName}" so it won't overlap with the main container
      # but the tailscale node won't have the "TS" prefix, which is unnecessary
      startsWithTS = substring 0 2 name == "TS";
      noTSname = if startsWithTS then substring 2 (-1) name else name;
    in
  {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          enable custom ${NAME} container module
        '';
      };
      volumeLocation = mkOption {
        type = types.str;
        default = "${dockerDataDir}/tailscale/${name}";
        description = ''
          path to store container volumes
        '';
      };
      imageVersion = mkOption {
        type = types.str;
        default = "latest";
        description = ''
          container image version
        '';
      };
      TSargs = mkOption {
        type = types.str;
        default = "";
        description = ''
          TS_Extra_ARGS env var
        '';
      };
      TShostname = mkOption {
        type = types.str;
        default = "${hostName}-${noTSname}";
        description = ''
          TS_HOSTNAME env var
        '';
      };
      TSserve = mkOption {
        type = with types; attrsOf str;
        default = {};
        description = ''
          paths that should map to ports for tailscale serve
        '';
        example = {
           "/" = "http://127.0.0.1:9000";
        };
      };
     enableFunnel = mkOption {
        type = types.bool;
        default = false;
        description = ''
          if you are sure you want to enable funnel
        '';
      };
     tags = mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["tag:services"];
        description = ''
          list of tags owned by "tag:container" to assign to the container
        '';
      };
    };
  };

  # Helper function to create a container configuration from a submodule
  mkContainer = name: cfg: 
  let
    formatTags = builtins.concatStringsSep "," cfg.tags;
    PathsToMap = a: b:  { Proxy = "${b}"; };
    Serveconfig = {
      TCP."443".HTTPS = true;
      Web."${cfg.TShostname}.${tailnetName}.ts.net:443".Handlers = lib.mapAttrs PathsToMap cfg.TSserve;
      AllowFunnel = {
          "${cfg.TShostname}.${tailnetName}.ts.net:443" = cfg.enableFunnel;
      };
    };

    # key = builtins.readFile config.age.secrets.tailscale.path;

    # # Generate the Tailscale auth environment file
    # tailscaleAuthEnvFile = pkgs.writeText "tailscale-auth-env" ''
    #   TS_AUTHKEY=${key}
    # '';

  in
  {
      image = "${IMAGE}:${cfg.imageVersion}";
      autoStart = true;
      hostname = cfg.TShostname;
      environment = lib.mkMerge [
      {
          "TS_HOSTNAME" = cfg.TShostname;
          "TS_STATE_DIR" = "/var/lib/tailscale";
          "TS_EXTRA_ARGS" = "--advertise-tags=" + formatTags + " " + cfg.TSargs;
          "TS_AUTHKEY" = builtins.readFile config.age.secrets.tailscale.path;
      }
      (lib.mkIf (cfg.TSserve != {}) {
          "TS_SERVE_CONFIG" = "config/tailscaleCfg.json";
          "TS_USERSPACE" = "true";
      })
      (lib.mkIf (cfg.TSserve == {}) {
           "TS_USERSPACE" = "false";
      })
      ];
      # environmentFiles = [
      #   config.age.secrets.tailscale.path
      #   # tailscaleAuthEnvFile
      # ];
      volumes = [
        "${cfg.volumeLocation}/data-lib:/var/lib"
        "/dev/net/tun:/dev/net/tun"
        "${(pkgs.writeTextFile {
          name = "${name}TScfg";
          text = builtins.toJSON Serveconfig;
        })}:/config/tailscaleCfg.json"
      ];
      extraOptions = [
        "--pull=always"
        "--cap-add=net_admin"
        "--cap-add=sys_module"
      ];
  };

  mkTmpfilesRules = name: cfg: [
    "d ${cfg.volumeLocation}/data-lib 0755 root root"
  ];
in
{
  options.roles.tsfunnel = {
    tailscaled = mkOption {
      default = {};
      type = with types; attrsOf (submodule containerOpts);
      example = {};
      description = lib.mdDoc ''
        Additional tailscale containers to pair with container services to expose on the tailnet.
      '';
    };
  };

  config = mkIf (config.roles.tsfunnel.tailscaled != {}) {
    age.secrets.tailscale.file = "${secrets}/tailscale-auth-key.age";

    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (name: cfg: mkTmpfilesRules name cfg) config.roles.tsfunnel.tailscaled);
    virtualisation.oci-containers.containers = lib.mapAttrs mkContainer config.roles.tsfunnel.tailscaled;
  };
}