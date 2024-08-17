{ config, pkgs, lib, ... }:
with lib;
let 
cfg = config.roles.ai;
appDataDir = "/storage/applications";
dockerDataDir = "/storage/docker";
in
{
  options.roles.ai = with types; {
    enable = mkEnableOption "Enable AI module";
  };

  config = mkIf cfg.enable {

    # We are using podman instead of docker for this.
    systemd.tmpfiles.rules = [
      # "d ${dockerDataDir} 0770 - media - -"
      "d ${dockerDataDir}/ollama 0770 - - - -"
      "d ${dockerDataDir}/open-webui 0770 - - - -"
    ];

    services.ollama = {
      #package = pkgs.unstable.ollama; # Uncomment if you want to use the unstable channel, see https://fictionbecomesfact.com/nixos-unstable-channel
      enable = true;
      acceleration = "cuda"; # Or "rocm"
      #environmentVariables = { # I haven't been able to get this to work myself yet, but I'm sharing it for the sake of completeness
        # HOME = "/home/ollama";
        # OLLAMA_MODELS = "/home/ollama/models";
        # OLLAMA_HOST = "0.0.0.0:11434"; # Make Ollama accesible outside of localhost
        # OLLAMA_ORIGINS = "http://localhost:8080,http://192.168.0.10:*"; # Allow access, otherwise Ollama returns 403 forbidden due to CORS
      #};
    };

    services.open-webui = {
      enable = true;
      port = 3000;
      openFirewall = true;
      environmentVariables = {
        OLLAMA_BASE_URL = "http://localhost:11434";
      };
    };


  };
}