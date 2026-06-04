# Defines the `host` trait's `nixos` class — maps each host node to a NixOS system.
{ inputs, ... }:
{
  # `nest.trait.host.class.nixos`: any node carrying `nest.host` gets built here.
  # First arg `{ node, ... }` receives the matched node (for node.system etc.).
  # Second arg `modules` is the list nest assembled from all matching rules.
  # Result lands in `evalResult.byClass.nixos.<nodeName>` — consumed in outs.nix.
  nest.trait.host.class.nixos =
    { node, ... }:
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (node) system; # pulls system from the node attrset in dom.nix
      inherit modules;
    };
}
