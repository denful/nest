{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.host;
      nixos = {
        boot.loader.grub.enable = false;
        fileSystems."/".device = "/dev/null";
        fileSystems."/".fsType = "auto";
      };
    }
  ];
}
