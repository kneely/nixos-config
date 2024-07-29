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

      # loadModels = ["llama3" "gemma2" "codegemma" "llama2-uncensored" "phi3" "deepseek-coder-v2" "qwen2"];

      # docker run -d -p 3000:8080 --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
      open-webui = {
        image = "ghcr.io/open-webui/open-webui:cuda";
        ports = [ "3000:8080" ];
        volumes = [ "${dockerDataDir}/open-webui:/app/backend/data" ];
        extraOptions = [ "--gpus=all"  ];
        environment = {
          OLLAMA_BASE_URL = "http://ollama:11434";
          USE_CUDA_DOCKER = "true";
          NVIDIA_VISIBLE_DEVICES = "all";
          NVIDIA_DRIVER_CAPABILITIES = "all";
        };
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."nixos.tail103fe.ts.net".extraConfig = ''
        reverse_proxy 127.0.0.1:3000 
      '';
      virtualHosts."nixos-open-webui.tail103fe.ts.net".extraConfig = ''
        reverse_proxy 127.0.0.1:3000 
      '';
    };

    roles.tsfunnel.tailscaled = {
      TSopen-webui = {
        enable = true;
        imageVersion = "latest";
        TSserve = {
          "/" = "http://open-webui:8080";
        };
        enableFunnel = true;
        tags = ["tag:services"];
      };
    };
  };
}