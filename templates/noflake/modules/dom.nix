# Identical to minimal/modules/dom.nix — flakes vs npins does not change the DOM.
{ nest, ... }:
{
  nest.igloo = {
    is = [ nest.host ]; # node declaration — see minimal/modules/dom.nix for detail
    system = "x86_64-linux";
  };
}
