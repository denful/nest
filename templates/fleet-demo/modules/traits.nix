# Trait definitions: entity-type traits (have class fns); marker traits = { }.
#
# Topology:
#   lb.needs = server → nginx + ssh + firewall
#   web.needs = server → nginx + ssh + firewall
#   monitoring.neededBy = server  (auto-injects on every server node)
{
  inputs,
  nest,
  lib,
  ...
}:
{
  # Entity-type traits
  #
  # host: passes the full list of NixOS module contributions to nixosSystem.
  # The module system merges them — nest does not deep-merge.
  nest.trait.host.class.nixos =
    { node, ... }:
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (node) system;
      inherit modules;
    };

  # user: Forward collects user-attr contributions as NixOS module fragments.
  # Each user child contributes one { users.users.<name> = …; } module to parent.
  nest.trait.user.class = {
    # Pass-through: user's own nixos contributions propagate to parent list.
    nixos = _select: modules: { nixos = modules; };
    # Produce a NixOS module fragment for the parent host's users.users.<name>.
    user =
      { node, ... }:
      modules: {
        nixos = [
          {
            users.users.${node.name} = lib.mkMerge modules;
          }
        ];
      };
  };

  # Service Marker traits
  nest.trait.nginx = { };
  nest.trait.ssh = { };
  nest.trait.firewall = { };

  # server = nginx + ssh + firewall
  nest.trait.server.needs = [
    nest.nginx
    nest.ssh
    nest.firewall
  ];

  # lb and web both imply server
  nest.trait.lb.needs = [ nest.server ];
  nest.trait.web.needs = [ nest.server ];

  # monitoring auto-injects on every server node (neededBy)
  nest.trait.monitoring = { };
  nest.trait.monitoring.neededBy = nest.server;

  # Role marker traits for users
  nest.trait.admin = { };
  nest.trait.deploy = { };
}
