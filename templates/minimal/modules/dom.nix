# ════════════════════════════════════════════════════════════
# nest template — MINIMAL
#
# Demonstrates: smallest viable single-host NixOS config —
#   one node, one trait, defaults applied via a rule
# Pick this when: starting from scratch and want the least
#   boilerplate possible
# Read order: dom.nix → traits.nix → rules.nix → outs.nix
# See also: ../default (adds users + standalone home-manager),
#           ../noflake (same idea, without flakes)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # "igloo" is a NODE: its value has `is`, so nest treats it as a machine.
  # Without `is` it would be a namespace wrapper — not a node, just grouping.
  nest.igloo = {
    is = [ nest.host ]; # declares the host trait → triggers nixos class below
    system = "x86_64-linux"; # node attribute; traits and rules can read this
  };
}
