_: {
  # dep: a flake dependency node — declares itself as a flake input.
  # modules is a list; fold it and merge with the node's own url.
  nest.trait.dep.class.flakeInput =
    { node, ... }: modules: { inherit (node) url; } // builtins.foldl' (a: b: a // b) { } modules;
}
