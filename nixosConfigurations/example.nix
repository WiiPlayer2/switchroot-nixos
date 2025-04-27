inputs:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    inputs.self.nixosModules.switchroot-nixos
    (
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        nixpkgs = {
          # buildPlatform = system;
          # buildPlatform = "x86_64-linux"; # TODO: for now only cross compilation
          # hostPlatform = "aarch64-linux";
          system = "aarch64-linux";
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "nvidia-x11"
              "nvidia-settings"
            ];
        };

        environment.systemPackages = with pkgs; [
          tmux
          btop
          nix-top
          nix-weather
          nvidiaPackages-l4t.tools
          onboard
          mesa-demos
          gdb
          gpu-viewer
          lshw
          alsa-utils
          ffmpeg-full
          difftastic
          file
        ];

        users.users.root.initialPassword = "nixos";
        users.users.nixos = {
          initialPassword = "nixos";
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "video"
            "audio"
          ];
        };
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };
        networking.networkmanager.enable = true;
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        services = {
          xserver = {
            enable = true;
            displayManager.lightdm = {
              enable = true;
              greeters = {
                gtk.enable = false;
                slick.enable = true; # supports onboard
              };
            };
            desktopManager.cinnamon.enable = true;
          };
          displayManager.defaultSession = "cinnamon";
        };

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/SWR-NIXOS";
            fsType = "ext4";
          };
        };
      }
    )
  ];
}
