# server trait: class.terranix produces a terranix config derivation.
# _select unused (no cross-node queries needed here — node data is enough).
# modules = list of terranix attrsets from matching rules, merged by terranix.
{ inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
in
{
  nest.trait.server.class.terranix =
    _select: modules:
    inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      inherit modules; # each rule contributes a terraform resource/provider block
    };
}
