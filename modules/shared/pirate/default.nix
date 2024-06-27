{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.services.mediaserver;
  dataDirBase = "/storage/media";
in {
  options.services.mediaserver.enable =
    mkEnableOption "Enable media server profile";

  config = mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d ${dataDirBase} 0770 - media - -"
      "d ${dataDirBase}/downloads 0770 - media - -"
      "d ${dataDirBase}/downloads/usenet 0770 - media - -"
      "e ${dataDirBase}/downloads/usenet/complete 0770 - media - -"
      "d ${dataDirBase}/downloads/usenet/incomplete 0770 - media - -"
      "d ${dataDirBase}/movies 0770 - media - -"
      "d ${dataDirBase}/tv 0770 - media - -"
    ];

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
        dataDir = "${dataDirBase}/radarr";
      };

      sonarr = {
        enable = true;
        user = "sonarr";
        group = "media";
        dataDir = "${dataDirBase}/sonarr";
      };

      jellyseerr = {
        enable = true;
        openFirewall = true;
      };

      jellyfin = {
        enable = true;
        user = "jellyfin";
        group = "media";
      };
    };
  };
}