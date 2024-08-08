{ config, pkgs, lib, ... }: {
  imports = [
    ./ai.nix
    ./authelia.nix
    ./nfs-bind.nix
    ./pirate.nix
    ./tailscale-service.nix
    ./tailscale-submodule.nix
    ./template.nix
    ./traefik.nix
    ./cf-tunnel.nix
  ];
}