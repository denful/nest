# Identical to minimal/modules/rules.nix — rules are input-system agnostic.
{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.host; # selects all host nodes — see minimal/modules/rules.nix
      nixos = {
        boot.loader.grub.enable = false;
        fileSystems."/".device = "/dev/null";
        fileSystems."/".fsType = "auto";
      };
    }
  ];
}
