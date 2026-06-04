# ════════════════════════════════════════════════════════════
# nest template — TERRANIX-DEMO
#
# Demonstrates: nest driving NON-NixOS IaC (Terraform via terranix);
#   node context (node.name, node.serverType, node.region) shapes
#   the terraform resource output per-node; class outputs a terranix
#   config derivation, not a system or package.
# Pick this when: generating Terraform configs from a nest DOM.
# Read order: dom.nix → traits.nix → rules.nix → outs.nix
# See also: ../nvf-standalone (non-NixOS target, package output)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # No namespace wrapper here — flat DOM, nodes at top level.
  # Node attrs (serverType, region) flow into rules via `node`.

  nest.web-1 = {
    is = [ nest.server ];
    serverType = "cx11"; # small Hetzner instance — accessed as node.serverType
    region = "nbg1"; # Hetzner location — accessed as node.region
  };

  nest.web-2 = {
    is = [ nest.server ];
    serverType = "cx21"; # larger instance — different type, same rule fires
    region = "fsn1";
  };
}
