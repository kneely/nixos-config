{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.roles.pirate;
  appDataDir = "/storage/applications";
  dataDirBase = "/storage/media";
in {
  options.roles.pirate.enable =
    mkEnableOption "Enable media server profile";

  config = mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${dataDirBase} 0770 - media - -"
      "d ${dataDirBase}/downloads 0770 - media - -"
      "d ${dataDirBase}/downloads/usenet 0770 - media - -"
      "d ${dataDirBase}/downloads/usenet/complete 0770 - media - -"
      "d ${dataDirBase}/downloads/usenet/incomplete 0770 - media - -"
      "d ${dataDirBase}/movies 0770 - media - -"
      "d ${dataDirBase}/tv 0770 - media - -"
    ];

    systemd.services."jellyfin".serviceConfig = {
      DeviceAllow = pkgs.lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
      PrivateDevices = pkgs.lib.mkForce true;
      RestrictAddressFamilies = pkgs.lib.mkForce [ "AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6" ];
    };

    services = {
      sabnzbd = {
        enable = true;
        user = "sabnzbd";
        group = "media";
        openFirewall = true;
        # settings = {
        #   MainDir = "${dataDirBase}/downloads/usenet";
        #   # ControlIP=0.0.0.0;
        # };
      };

      prowlarr.enable = true;

      radarr = {
        enable = true;
        user = "radarr";
        group = "media";
        dataDir = "${appDataDir}/radarr";
      };

      sonarr = {
        enable = true;
        user = "sonarr";
        group = "media";
        dataDir = "${appDataDir}/sonarr";
      };

      bazarr = {
        enable = true;
        user = "bazarr";
        group = "media";
        # dataDir = "${appDataDir}/bazarr";
        openFirewall = true;
      };

      jellyseerr = {
        enable = true;
        openFirewall = true;
      };

      jellyfin = {
        enable = true;
        user = "jellyfin";
        group = "media";
        openFirewall = true;
      };
    };
  };
}