{ config, pkgs, lib, ... }: {
  imports = [
    ./authelia.nix
    ./nfs-bind.nix
    ./pirate.nix
    ./tailscale.nix
    ./template.nix
    ./traefik.nix
  ];
}