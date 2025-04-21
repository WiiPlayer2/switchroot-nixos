{ nvidia-drivers
, runCommand
}:
runCommand "nvidia-l4t-tegra-firmware" {} ''
  mkdir -p $out
  cp --no-preserve=mode -r ${nvidia-drivers}/lib $out/
  cd $out/lib/firmware/gm20b
  for file in *; do
    rm $file
    ln -s ${nvidia-drivers}/lib/firmware/tegra21x/$file $file
  done
''
