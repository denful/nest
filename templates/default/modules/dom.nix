# ════════════════════════════════════════════════════════════
# nest template — DEFAULT
#
# Demonstrates: host+user nesting, standalone home-manager,
#   has()/attr/descendant selectors, trait-arg context lookup
# Pick this when: learning nest from scratch
# Read order: modules/dom.nix → rules/host-defaults.nix →
#   rules/user-account.nix → rules/host-hm.nix → rules/tux.nix
#   → rules/hm-defaults.nix → modules/outs.nix
# See also: ../minimal (simpler starting point),
#           ../fleet-demo (advanced multi-host)
# ════════════════════════════════════════════════════════════
#
# DOM = nested attrset. A node = has `is = [traits]`.
# A key WITHOUT `is` (like `nest.igloo.tux`) is a NAMESPACE:
# it organises the tree and its scalar attrs inherit downward.
#
# Read rules/* after this file.
{ nest, ... }:
{
  # NODE: igloo carries the `host` trait → produces nixosConfigurations.igloo
  nest.igloo = {
    is = [ nest.host ];
    system = "x86_64-linux";

    # Remove for real hardware.
    boot = false;

    # NAMESPACE wrapper: `igloo.tux` is child scope, not itself a node.
    # Scalar attrs here (e.g. admin) propagate to child nodes automatically.
    # NODE: tux carries `host.user` → hosted home-manager inside igloo.
    tux = {
      is = [ nest.host.user ];
      admin = true; # inherited by rules — see rules/user-account.nix [admin=true]
    };
  };

  # Standalone HM: NOT nested under a host — its own DOM root node.
  # Produces homeConfigurations.tux without any NixOS host.
  nest.tux = {
    is = [ nest.home ];
    system = "x86_64-linux";
  };
}
