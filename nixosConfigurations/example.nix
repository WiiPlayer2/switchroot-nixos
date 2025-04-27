inputs:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    inputs.self.nixosModules.switchroot-nixos
    (
      { lib, pkgs, config, ... }:
      let
        set-alsa-config = (pkgs.writeShellScriptBin "set-alsa-config" ''
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="I2S1 Sample Rate" 48000
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x SPK MIXL DAC L1 Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x SPK MIXR DAC R1 Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x SPOL MIX SPKVOL L Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x SPOR MIX SPKVOL R Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Speaker Channel Switch" on,on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Speaker L Playback Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Speaker R Playback Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Stereo DAC MIXL DAC L1 Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Stereo DAC MIXR DAC R1 Switch" on
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="I2S1 Mux" 1
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="ADMAIF1 Mux" 11
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x DAC1 HP Playback Volume" 126,126
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x DAC1 Playback Volume" 126,126
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x DAC1 Speaker Playback Volume" 126,126
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x HP Playback Volume" 0,0
          ${pkgs.alsa-utils}/bin/amixer -c1 cset name="x Speaker Playback Volume" 35,35
          echo "Internal audio initialized."
        '');
      in
      {
        nixpkgs = {
          # buildPlatform = system;
          # buildPlatform = "x86_64-linux"; # TODO: for now only cross compilation
          # hostPlatform = "aarch64-linux";
          system = "aarch64-linux";
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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

          set-alsa-config
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

        boot.kernelPackages = pkgs.linuxPackages_4_9-l4t.cross-compiled;
        hardware.firmware = with pkgs; [
          config.boot.kernelPackages.kernel
          nvidiaPackages-l4t.tegra-firmware
        ];
        hardware.enableRedistributableFirmware = true;
        hardware.bluetooth.enable = true;
        services.pipewire = {
          # package = pkgs.pipewire-with-tegra;
          wireplumber = {
            extraConfig = {
              "log-level-debug" = {
                "context.properties" = {
                  # Output Debug log messages as opposed to only the default level (Notice)
                  "log.level" = "D";
                };
              };
              tegra-nx = {
                "monitor.alsa.rules" = [
                  {
                    matches = [
                      { "device.nick" = "tegra-snd-t210ref-mobile-rt565x"; }
                    ];
                    actions = {
                      update-props = {
                        "audio.format" = "S16LE";
                        "audio.rate" = 48000;
                      };
                    };
                  }
                ];
              };
            };
          };
        };
        systemd.services.tegra-speaker-init = {
          wantedBy = [ "sound.target" ];
          script = ''
            ${lib.getExe set-alsa-config}
          '';
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
