# ════════════════════════════════════════════════════════════
# nest template — FLAKE-FILE
#
# Demonstrates: flake inputs modeled as DOM nodes via `dep` trait;
#   `flakeInput` class turns each node into a flake input entry;
#   flake-file tool consumes byClass.flakeInput to write flake.nix
# Pick this when: you want nest to manage your flake inputs declaratively
# Read order: modules/dom.nix → modules/traits.nix →
#             modules/outs.nix → outputs.nix
# See also: ../default (no input management),
#           ../noflake (npins alternative for input pinning)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # NAMESPACE `deps` — organises all dependency nodes in one scope.
  # Each child carries `is = [nest.dep]` → becomes a flake input entry.
  nest.deps = {
    import-tree = {
      is = [ nest.dep ]; # dep trait: `flakeInput` class reads node.url
      url = "github:vic/import-tree";
    };

    nixpkgs = {
      is = [ nest.dep ];
      url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    };

    flake-file = {
      is = [ nest.dep ];
      url = "github:vic/flake-file";
    };

    nest = {
      is = [ nest.dep ];
      url = "github:vic/nest";
    };
  };

}
