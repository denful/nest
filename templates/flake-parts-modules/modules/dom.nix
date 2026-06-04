# ════════════════════════════════════════════════════════════
# nest template — FLAKE-PARTS-MODULES
#
# Demonstrates: flake-parts integration + `synth`;
#   synth enriches a node (injects node.pkgs) BEFORE its class runs,
#   so rules/classes can consume derived data without recomputing it
# Pick this when: using flake-parts + need per-node derived data (e.g. pkgs)
# Read order: modules/dom.nix → modules/traits.nix →
#             modules/rules.nix → modules/outs.nix
# See also: ../default (no synth, simpler),
#           ../terranix-demo (different flake-parts use-case)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # NODE: `default` carries the `shell` trait.
  # `shell` has a synth fn (see traits.nix) that injects node.pkgs
  # before the `devshell` class runs — so rules.nix can use select.node.pkgs.
  nest.default = {
    is = [ nest.shell ];
    system = "x86_64-linux";
  };
}
