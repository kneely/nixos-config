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

    virtualisation.oci-containers.containers = {
      # docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
      # ollama = {
      #   image = "ollama/ollama:latest";
      #   ports = [ "11434:11434" ];
      #   volumes = [ "${dockerDataDir}/ollama:/root/.ollama" ];
      #   extraOptions = [ "--gpus=all" "--pull=newer"  ];
      #   environment = {
      #     NVIDIA_VISIBLE_DEVICES = "all";
      #     NVIDIA_DRIVER_CAPABILITIES = "all";
      #     OLLAMA_ORIGINS = "*";
      #     # PUID = "600";
      #     # PGID = "600";
      #   };
      # };

      # loadModels = ["llama3" "gemma2" "codegemma" "llama2-uncensored" "phi3" "deepseek-coder-v2" "qwen2"];

      # docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
      open-webui = {
        image = "ghcr.io/open-webui/open-webui:main";
        # ports = [ "3000:8080" ];
        volumes = [ "${dockerDataDir}/open-webui:/app/backend/data" ];
        extraOptions = [ "--pull=newer" "--network=host" "--add-host=host.containers.internal:host-gateway"  ];
        environment = {
          PORT = "3000";
          OLLAMA_BASE_URL = "http://localhost:11434";
          # USE_CUDA_DOCKER = "true";
          # NVIDIA_VISIBLE_DEVICES = "all";
          # NVIDIA_DRIVER_CAPABILITIES = "all";
        };
      };
    };

    # services.caddy = {
    #   enable = true;
    #   virtualHosts."nixos.tail103fe.ts.net".extraConfig = ''
    #     reverse_proxy 127.0.0.1:3000 
    #   '';
    #   virtualHosts."nixos-open-webui.tail103fe.ts.net".extraConfig = ''
    #     reverse_proxy 127.0.0.1:3000 
    #   '';
    # };

    # roles.tsfunnel.tailscaled = {
    #   TSopen-webui = {
    #     enable = true;
    #     imageVersion = "latest";
    #     TSserve = {
    #       "/" = "http://open-webui:8080";
    #     };
    #     enableFunnel = true;
    #     tags = ["tag:services"];
    #   };
    # };
  };
}