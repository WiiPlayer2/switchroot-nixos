{ pkgs, lib, ... }:

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
  environment.systemPackages = [
          set-alsa-config
  ];
  
        services.pipewire = {
          # package = pkgs.pipewire-with-tegra;
          wireplumber = {
            extraConfig = {
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
}
