{ nv-tools
, stdenv
, autoPatchelfHook
}:
stdenv.mkDerivation {
  name = "nvidia-l4t-tools";
  version = nv-tools.version;

  src = nv-tools;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    mkdir -p $out/bin
    runHook preInstall
    cp --no-preserve=mode usr/bin/* $out/bin/
    cp --no-preserve=mode usr/sbin/* $out/bin/
    chmod +x $out/bin/*
    runHook postInstall
  '';
}
