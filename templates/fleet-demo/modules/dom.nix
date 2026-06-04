# ════════════════════════════════════════════════════════════
# nest template — FLEET-DEMO
#
# Demonstrates: multi-host topology via NAMESPACES (prod/staging as
#   namespace wrappers, not nodes); needs/neededBy trait dependency
#   graph; select.siblings scoped to the enclosing namespace; classless
#   marker traits for user-registry nodes.
# Pick this when: managing multiple NixOS hosts across environments.
# Read order: dom.nix → traits.nix → rules.nix → outs.nix
# See also: ../default (single host, simpler starting point),
#           ../minimal (bare minimum, no traits/rules)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # nest.prod and nest.staging are NAMESPACES, not nodes — no `is`.
  # Scalar attrs set here (system, env) are inherited by every child node.
  # select.siblings inside a prod node returns only other prod children.
  nest.prod.system = "x86_64-linux";
  nest.prod.env = "prod";

  nest.staging.system = "x86_64-linux";
  nest.staging.env = "staging";

  # prod: load balancer + two web servers
  # nest.lb implies nest.server (via needs) → nginx + ssh + firewall auto-added.
  nest.prod.lb-prod = {
    is = [
      nest.host
      nest.lb # needs = [server] → needs = [nginx ssh firewall]
    ];
    addr = "10.0.1.1";
    httpPort = 80;
  };
  nest.prod.web-prod-1 = {
    is = [
      nest.host
      nest.web # needs = [server] same chain
    ];
    addr = "10.0.1.10";
    httpPort = 80;
  };
  nest.prod.web-prod-2 = {
    is = [
      nest.host
      nest.web
    ];
    addr = "10.0.1.11";
    httpPort = 80;
  };

  # staging namespace: siblings scope stops at namespace boundary.
  # web-staging's select.siblings never sees prod hosts.
  nest.staging.web-staging = {
    is = [
      nest.host
      nest.web
    ];
    addr = "10.0.2.10";
    httpPort = 80;
  };

  # User registry: marker traits only — no class, so no output produced.
  # nest.admin / nest.deploy are classless; traverseDom still visits them
  # so select nest.admin can find alice from any rule. Rules synth these
  # into virtual children under host nodes (see rules.nix).
  nest.users.alice = {
    is = [ nest.admin ];
    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyAlice alice@workstation" ];
  };
  nest.users.bob = {
    is = [ nest.deploy ];
    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyBob bob@laptop" ];
  };

}
