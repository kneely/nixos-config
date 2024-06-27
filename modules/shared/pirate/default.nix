{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.services.mediaserver;
  dataDirBase = "/storage/media";
in {
  options.services.mediaserver.enable =
    mkEnableOption "Enable media server profile";

  config = mkIf cfg.enable {

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

      jellyfin = {
        enable = true;
        user = "jellyfin";
        group = "media";
      };
    };
  };
}