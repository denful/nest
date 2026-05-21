{ inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
in
{
  nest.trait.server.class.terranix =
    _select: modules:
    inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      inherit modules;
    };
}
