# Trait definitions for the flake-file template.
# `dep` trait + `flakeInput` class: each dep node → one flake input attrset.
_: {
  # `flakeInput` class assembles one input entry:
  #   1. seed with node.url (the canonical flake input field)
  #   2. fold/merge `modules` (other class contributions) on top
  # Result lives in byClass.flakeInput — consumed by outs.nix → flake-file.
  nest.trait.dep.class.flakeInput =
    { node, ... }: modules: { inherit (node) url; } // builtins.foldl' (a: b: a // b) { } modules;
}
