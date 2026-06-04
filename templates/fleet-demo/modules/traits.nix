# Trait definitions for fleet-demo.
# Two kinds: entity traits (have class = output fn) and marker traits (= {}).
#
# needs/neededBy dependency graph:
#   lb ──needs──> server ──needs──> nginx, ssh, firewall
#   web ─needs──> server (same)
#   monitoring ──neededBy──> server  (inverse: auto-injects into every server node)
#
# So declaring `is = [nest.lb]` on a node silently adds nginx+ssh+firewall+monitoring.
{
  inputs,
  nest,
  lib,
  ...
}:
{
  # host: entity trait. class.nixos receives collected module list → calls nixosSystem.
  # The `system` attr comes from the namespace (dom.nix nest.prod.system).
  nest.trait.host.class.nixos =
    { node, ... }:
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (node) system;
      inherit modules;
    };

  # user: dual-class trait.
  # class.nixos = pass-through so a user node's nixos contributions reach its host.
  # class.user = wraps attrs into a users.users.<name> NixOS module fragment,
  #   which the host's nixos class then merges into the system.
  nest.trait.user.class = {
    nixos = _select: modules: { nixos = modules; };
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

  # Marker traits: no class → no output. Used only for selector matching.
  nest.trait.nginx = { };
  nest.trait.ssh = { };
  nest.trait.firewall = { };

  # needs: transitive. Any node with nest.server gets nginx+ssh+firewall added.
  nest.trait.server.needs = [
    nest.nginx
    nest.ssh
    nest.firewall
  ];

  # lb/web declare needs=[server]; server's own needs chain transitively.
  nest.trait.lb.needs = [ nest.server ];
  nest.trait.web.needs = [ nest.server ];

  # neededBy = server: inverse of needs. monitoring auto-attaches to every
  # node that carries nest.server — no explicit declaration in dom.nix needed.
  nest.trait.monitoring = { };
  nest.trait.monitoring.neededBy = nest.server;

  # Role markers: classless, used only by select in rules.nix synth blocks.
  nest.trait.admin = { };
  nest.trait.deploy = { };
}
