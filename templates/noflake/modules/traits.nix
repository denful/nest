# Identical to minimal/modules/traits.nix — `inputs` here comes from npins, not flakes.
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
