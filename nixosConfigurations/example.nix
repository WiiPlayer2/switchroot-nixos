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
        ];

        users.users.root.initialPassword = "nixos";
        users.users.nixos = {
          initialPassword = "nixos";
          isNormalUser = true;
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
                gtk.enable = true;
                # tiny.enable = true;
              };
              extraConfig = ''
                logind-check-graphical=false
              '';
            };
            # desktopManager.cinnamon.enable = true;
            desktopManager.xterm.enable = true;
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
          displayManager.defaultSession = "xterm";
        };
        boot.blacklistedKernelModules = [
          "nouveau"
          "nvidiafb"
        ];
        boot.kernelModules = [
          "nvgpu"
        ];

        boot.kernelPackages = pkgs.linuxPackages_4_9-l4t;
        hardware.firmware = with pkgs; [
          linuxPackages_4_9-l4t.kernel
          nvidiaPackages-l4t.tegra-firmware
        ];
        hardware.enableRedistributableFirmware = true;
        # hardware.nvidia.enabled = true;
        hardware.nvidia.open = false;
        hardware.nvidia.package = null;
        nixpkgs.config.nvidia.acceptLicense = true;

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/SWR-NIXOS";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/mmcblk0p1";
            fsType = "vfat";
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
        system.build.switchrootImage = pkgs.switchroot-nixos {
          inherit (config.system.build) kernel initialRamdisk toplevel;
        };
      }
    )
  ];
}
