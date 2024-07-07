{ config, pkgs, lib, ... }:
with lib;
let 
cfg = config.roles.ai;
appDataDir = "/storage/applications";
in
{
  options.roles.ai = with types; {
    enable = mkEnableOption "Enable AI module";
  };

  config = mkIf cfg.enable {
    # Enable Authelia
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      home = "${appDataDir}/ollama";
      models = "${appDataDir}/ollama/models";
      loadModels = ["llama3" "gemma2" "codegemma" "llama2-uncensored" "phi3" "deepseek-coder-v2" "qwen2"];
    };

    services.open-webui = {
      enable = true;
      stateDir = "${appDataDir}/open-webui";
      openFirewall = true;
      port = 8081;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
  };
}