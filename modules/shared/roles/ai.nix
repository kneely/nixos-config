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

    virtualisation.oci-containers.containers = {
      # docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
      ollama = {
        image = "ollama/ollama:latest";
        ports = [ "11434:11434" ];
        volumes = [ "${dockerDataDir}/ollama:/root/.ollama" ];
        extraOptions = [ "--gpus=all"  ];
        environment = {
          NVIDIA_VISIBLE_DEVICES = "all";
          NVIDIA_DRIVER_CAPABILITIES = "all";
          OLLAMA_ORIGINS = "*";
          # PUID = "600";
          # PGID = "600";
        };
      };

      # docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
      open-webui = {
        image = "ghcr.io/open-webui/open-webui:cuda";
        ports = [ "8081:8080" ];
        volumes = [ "${dockerDataDir}/open-webui:/app/backend/data" ];
      };

      # docker run -d -p 3000:8080 --gpus=all -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
      # open-webui-ollama = {
      #   image = "ghcr.io/open-webui/open-webui:ollama";
      #   ports = [ "8081:8080" ];
      #   volumes = [ "${dockerDataDir}/open-webui:/app/backend/data" "${dockerDataDir}/ollama:/root/.ollama" ];
      #   extraOptions = [ "--gpus=all" "--device=nvidia.com/gpu=all" ];
      # };
    };


    # services.ollama = {
    #   enable = true;
    #   acceleration = "cuda";
    #   home = "${appDataDir}/ollama";
    #   models = "${appDataDir}/ollama/models";
    #   # loadModels = ["llama3" "gemma2" "codegemma" "llama2-uncensored" "phi3" "deepseek-coder-v2" "qwen2"];
    #   loadModels = ["phi3" ];
    # };

    # services.open-webui = {
    #   enable = true;
    #   stateDir = "${appDataDir}/open-webui";
    #   openFirewall = true;
    #   port = 8081;
    #   environment = {
    #     ANONYMIZED_TELEMETRY = "False";
    #     DO_NOT_TRACK = "True";
    #     SCARF_NO_ANALYTICS = "True";
    #   };
    # };
  };
}