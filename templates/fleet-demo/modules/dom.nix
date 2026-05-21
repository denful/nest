# Fleet topology: two environments, four hosts, policy-driven user access.
#
# DOM namespace = environment:
#   nest.prod.*    — prod hosts (lb-prod, web-prod-1, web-prod-2)
#   nest.staging.* — staging hosts (web-staging)
#
# select.siblings from any host returns peers in same environment only.
# This is akin to Den's pipe.collect scope boundary.
#
# Users:
#   alice (admin)  — all hosts in prod + staging
#   bob   (deploy) — staging only
{ nest, ... }:
{
  nest.prod.system = "x86_64-linux";
  nest.prod.env = "prod";

  nest.staging.system = "x86_64-linux";
  nest.staging.env = "staging";

  # prod: load balancer + two web servers
  nest.prod.lb-prod = {
    is = [
      nest.host
      nest.lb
    ];
    addr = "10.0.1.1";
    httpPort = 80;
  };
  nest.prod.web-prod-1 = {
    is = [
      nest.host
      nest.web
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

  # staging: single web server
  nest.staging.web-staging = {
    is = [
      nest.host
      nest.web
    ];
    addr = "10.0.2.10";
    httpPort = 80;
  };

  # User registry: marker traits only — no class needed.
  # traverseDom includes any node with `is = [...]`; select can find them.
  # processNode returns null for classless nodes so they never reach nixosConfigurations.
  nest.users.alice = {
    is = [ nest.admin ];
    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyAlice alice@workstation" ];
  };
  nest.users.bob = {
    is = [ nest.deploy ];
    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyBob bob@laptop" ];
  };

}
