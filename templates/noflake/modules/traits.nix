{ inputs, ... }:
{
  nest.trait.host.class.nixos =
    { node, ... }:
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (node) system;
      inherit modules;
    };
}
