{ config, pkgs, lib, home-manager, ... }:

let
  user = "kevin";
  # Define the content of your file as a derivation
  # myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
  #   #!/bin/sh
  #   emacsclient -c -n &
  # '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  security.pam.enableSudoTouchIdAuth = true;

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          # { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

        shellAliases = {
          hmb = "nix run ~/nixos-config/.#build";
          hmbs = "nix run ~/nixos-config/.#build-switch";
        };

        sessionVariables = {
          NIX_CONFIG_DIR = "$HOME/nixos-config";
        };

        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = { 
    dock = {
      enable = true;
      entries = [
        { path = "/Applications/Arc.app/"; }
        { path = "${pkgs.wezterm}/Applications/Wezterm.app/"; }
        # Visual Studio Code
        { path = "/Applications/Visual Studio Code.app/"; }
        # { path = "/System/Applications/Music.app/"; }
        # { path = "/System/Applications/News.app/"; }
        # { path = "/System/Applications/Photos.app/"; }
        # { path = "/System/Applications/Photo Booth.app/"; }
        # { path = "/System/Applications/TV.app/"; }
        # { path = "/System/Applications/Home.app/"; }
        # {
        #   path = toString myEmacsLauncher;
        #   section = "others";
        # }
        {
          path = "${config.users.users.${user}.home}/.local/share/";
          section = "others";
          options = "--sort name --view grid --display folder";
        }
        {
          path = "${config.users.users.${user}.home}/.local/share/downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
