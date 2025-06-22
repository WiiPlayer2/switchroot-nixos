{ runCommand }:
runCommand "nvpmodel-profiles" {} ''
  mkdir -p $out/etc/nvpmodel
  ln -s ${./files/nvpmodel_charging.conf} $out/etc/nvpmodel/nvpmodel_charging.conf
  ln -s ${./files/nvpmodel_t210.conf} $out/etc/nvpmodel/nvpmodel_t210.conf
  ln -s ${./files/nvpmodel_t210b01.conf} $out/etc/nvpmodel/nvpmodel_t210b01.conf
''
