{ config
, runCommand
}:
runCommand "nvidia-l4t-alsa-config" {} ''
  mkdir -p -p $out/share
  ln -s ${config}/usr/share/alsa $out/share/
''
