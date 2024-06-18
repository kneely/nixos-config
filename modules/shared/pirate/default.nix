{ pkgs, lib, config, ... }:
with lib;
let 
  cfg = config.profiles.mediaserver;
  dataDirBase = "/pool/media";
in {
  options.profiles.mediaserver.enable =
    mkEnableOption "Enable media server profile";

  config = mkIf cfg.enable {

    services = {
      sabnzbd = {
        enable = true;
        user = "sabnzbd";
        group = "media";
        # settings = {
        #   MainDir = "${dataDirBase}/downloads/usenet";
        #   # ControlIP=0.0.0.0;
        # };
      };

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

      jellyfin.enable = true;
    };
  };
}