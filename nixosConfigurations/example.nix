inputs:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    (
      { lib, pkgs, config, ... }:
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
          nvidiaPackages-l4t.alsa-config
          alsa-utils
          ffmpeg-full
          nvidiaPackages-l4t.sources.config
          difftastic

          (writeShellScriptBin "set-alsa-config" ''
            # RT565x playback setup
            amixer -c1 cset name="x Headphone Playback Volume" "31,31"
            amixer -c1 cset name="x Stereo DAC MIXR DAC R1 Switch" "on"
            amixer -c1 cset name="x Stereo DAC MIXL DAC L1 Switch" "on"
            amixer -c1 cset name="x HPO R Playback Switch" "on"
            amixer -c1 cset name="x HPO L Playback Switch" "on"
            amixer -c1 cset name="x DAC1 Playback Volume" "175,175"
            amixer -c1 cset name="x DAC1 Speaker Playback Volume" "175,175"
            amixer -c1 cset name="x DAC1 Playback Switch" "on"
            amixer -c1 cset name="x DAC1 MIXR DAC1 Switch" "on"
            amixer -c1 cset name="x DAC1 MIXL DAC1 Switch" "on"

            # RT565x capture setup
            amixer -c1 cset name="x RECMIX1L BST1 Switch" "on"
            amixer -c1 cset name="x RECMIX1R BST1 Switch" "on"
            amixer -c1 cset name="x Stereo1 ADC Source" "ADC1"
            amixer -c1 cset name="x Stereo1 ADC1 Source" "ADC"
            amixer -c1 cset name="x Stereo1 ADC MIXL ADC1 Switch" "on"
            amixer -c1 cset name="x Stereo1 ADC MIXR ADC1 Switch" "on"
            amixer -c1 cset name="x TDM Data Mux" "AD1:AD2:DAC:NUL"
            amixer -c1 cset name="x IN1 Boost Volume" "43"
            echo "Initialised RT565x codec with prefix 'x'"

            # RT565x playback setup
            amixer -c1 cset name="y Headphone Playback Volume" "31,31"
            amixer -c1 cset name="y Stereo DAC MIXR DAC R1 Switch" "on"
            amixer -c1 cset name="y Stereo DAC MIXL DAC L1 Switch" "on"
            amixer -c1 cset name="y HPO R Playback Switch" "on"
            amixer -c1 cset name="y HPO L Playback Switch" "on"
            amixer -c1 cset name="y DAC1 Playback Volume" "175,175"
            amixer -c1 cset name="y DAC1 Playback Switch" "on"
            amixer -c1 cset name="y DAC1 MIXR DAC1 Switch" "on"
            amixer -c1 cset name="y DAC1 MIXL DAC1 Switch" "on"

            # RT565x capture setup
            amixer -c1 cset name="y RECMIX1L BST1 Switch" "on"
            amixer -c1 cset name="y RECMIX1R BST1 Switch" "on"
            amixer -c1 cset name="y Stereo1 ADC Source" "ADC1"
            amixer -c1 cset name="y Stereo1 ADC1 Source" "ADC"
            amixer -c1 cset name="y Stereo1 ADC MIXL ADC1 Switch" "on"
            amixer -c1 cset name="y Stereo1 ADC MIXR ADC1 Switch" "on"
            amixer -c1 cset name="y TDM Data Mux" "AD1:AD2:DAC:NUL"
            amixer -c1 cset name="y IN1 Boost Volume" "43"
            echo "Initialised RT565x codec with prefix 'y'"

            amixer -c1 cset name="I2S1 Sample Rate" 48000
            amixer -c1 cset name="x SPK MIXL DAC L1 Switch" on
            amixer -c1 cset name="x SPK MIXR DAC R1 Switch" on
            amixer -c1 cset name="x SPOL MIX SPKVOL L Switch" on
            amixer -c1 cset name="x SPOR MIX SPKVOL R Switch" on
            amixer -c1 cset name="x Speaker Channel Switch" on,on
            amixer -c1 cset name="x Speaker L Playback Switch" on
            amixer -c1 cset name="x Speaker R Playback Switch" on
            amixer -c1 cset name="x Stereo DAC MIXL DAC L1 Switch" on
            amixer -c1 cset name="x Stereo DAC MIXR DAC R1 Switch" on
            amixer -c1 cset name="I2S1 Mux" 1
            amixer -c1 cset name="ADMAIF1 Mux" 11
          '')
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
              extraConfig = ''
                logind-check-graphical=false
              '';
            };
            desktopManager.cinnamon.enable = true;
            videoDrivers = [ "nvidia" ];
            drivers = [
              {
                name = "nvidia";
                modules = [ pkgs.nvidiaPackages-l4t.x11-module ];
                # driverName = "nvidia";
                display = true;
                screenSection = ''
                  Option         "metamodes" "DSI-0: nvidia-auto-select @1280x720 +0+0 {ViewPortIn=1280x720, ViewPortOut=720x1280+0+0, Rotation=90}"
                '';
              }
            ];
            monitorSection = ''
              ModelName   "DFP-0"
              #DisplaySize 77 137
            '';
            deviceSection = ''
              Option      "AllowUnofficialGLXProtocol" "true"
              Option      "DPMS" "false"
              # Allow X server to be started even if no display devices are connected.
              Option      "AllowEmptyInitialConfiguration" "true"
              Option      "Monitor-DSI-0" "Monitor[0]"
              # Option      "Monitor-DP-0" "Monitor1"
            '';
          };
          displayManager.defaultSession = "cinnamon";
          udev.packages = with pkgs; [
            nvidiaPackages-l4t.udev-rules
          ];
        };
        boot.blacklistedKernelModules = [
          "nouveau"
          "nvidiafb"
        ];
        boot.kernelModules = [
          "nvgpu"
        ];

        boot.kernelPackages = pkgs.linuxPackages_4_9-l4t.cross-compiled;
        hardware.firmware = with pkgs; [
          config.boot.kernelPackages.kernel
          nvidiaPackages-l4t.tegra-firmware
        ];
        hardware.enableRedistributableFirmware = true;
        # hardware.nvidia.enabled = true;
        hardware.nvidia.open = false;
        hardware.nvidia.package = null;
        nixpkgs.config.nvidia.acceptLicense = true;
        hardware.bluetooth.enable = true;
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            nvidiaPackages-l4t.tegra-lib
          ];
        };
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
        environment.etc = {
          "alsa/conf.d/99-tegra.conf".text = ''
            <confdir:pcm/front.conf>

            pcm.front {
              @args [ CARD ]
              @args.CARD {
                type string
              }
              type hw
              card $CARD
            }
          '';
        };

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/SWR-NIXOS";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/mmcblk0p1";
            fsType = "vfat";
            noCheck = true;
          };
        };

        boot.initrd.postDeviceCommands = ''
          echo 0 > /sys/class/graphics/fb0/state
        '';

        nixpkgs.overlays = [
          inputs.self.overlays.switchroot-nixos
          (final: prev: {
            xorg = prev.xorg.overrideScope (final': prev': {
              xorgserver = prev'.xorgserver.overrideAttrs (prevAttrs: {
                version = "1.20.14";
                src = prev.fetchurl {
                  url = "mirror://xorg/individual/xserver/xorg-server-1.20.14.tar.gz";
                  hash = "sha256-VLGZySgP+L8Pc6VKdZZFvQ7u2nJV0cmTENW3WV86wGY=";
                };
                patches = prevAttrs.patches ++ [
                  # https://github.com/NixOS/nixpkgs/pull/147238
                  (prev.fetchpatch {
                    name = "stdbool.patch";
                    url = "https://gitlab.freedesktop.org/xorg/xserver/-/commit/454b3a826edb5fc6d0fea3a9cfd1a5e8fc568747.diff";
                    sha256 = "1l9qg905jvlw3r0kx4xfw5m12pbs0782v2g3267d1m6q4m6fj1zy";
                  })
                ];
              });
            });
          })
        ];

        boot.loader.grub.enable = false;
        boot.loader.external = {
          enable = true;
          installHook =
            let
              switchroot-boot = (pkgs.switchroot-nixos {
                  inherit (config.system.build) kernel initialRamdisk toplevel;
                }).boot;
              installApplication = pkgs.writeShellApplication {
                name = "install-boot-config";
                text = ''
                  TOPLEVEL="$1"
                  cp -v ${switchroot-boot.uImage} /boot/switchroot/nixos/uImage
                  cp -v ${switchroot-boot.uInitrd} /boot/switchroot/nixos/initramfs
                  cp -v ${switchroot-boot.dtb-image} /boot/switchroot/nixos/nx-plat.dtimg
                  ${switchroot-boot.boot-scr.buildScript}/bin/build-boot-scr "$TOPLEVEL" /boot/switchroot/nixos/boot.scr
                '';
              };
            in
              pkgs.lib.getExe installApplication;
        };
        system.build.switchrootImage = pkgs.switchroot-nixos {
          inherit (config.system.build) kernel initialRamdisk toplevel;
        };
      }
    )
  ];
}
