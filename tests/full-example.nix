nest:
let
  inherit (nest) nestTest;
in
{
  "full-example" = {

    # Mirrors design.md section 8 (simplified, no nixpkgs.lib.nixosSystem)
    test-full-design = nestTest (
      {
        nest,
        lb,
        web-1,
        ...
      }:
      let
        t = nest;
      in
      {
        # traits
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.nginx = { };
        nest.trait.ssh = { };
        nest.trait.firewall = { };
        nest.trait.server.needs = traits: [
          traits.nginx
          traits.ssh
          traits.firewall
        ];
        nest.trait.monitoring = { };
        nest.trait.monitoring.neededBy = t.server;
        nest.trait.web = { };
        nest.trait.lb.needs = traits: [ traits.server ];
        nest.trait.admin = { };

        # dom
        nest.prod.lb = {
          is = [
            t.host
            t.lb
          ];
          system = "x86_64-linux";
          addr = "10.0.0.1";
        };
        nest.prod.web-1 = {
          is = [
            t.host
            t.web
          ];
          system = "x86_64-linux";
          addr = "10.0.0.2";
          port = 80;
        };
        nest.prod.web-2 = {
          is = [
            t.host
            t.web
          ];
          system = "x86_64-linux";
          addr = "10.0.0.3";
          port = 80;
        };
        nest.prod.web-1.users.alice = {
          is = [
            t.user
            t.admin
          ];
          sshKeys = [ "ssh-ed25519 abc" ];
        };

        # rules
        nest.rules = [
          {
            is = t.host;
            nixos.nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
          {
            is = t.nginx;
            nixos.services.nginx.enable = true;
          }
          {
            is = t.ssh;
            nixos.services.openssh.enable = true;
          }
          {
            is = t.firewall;
            nixos.networking.firewall.enable = true;
          }
          {
            is = t.monitoring;
            nixos.services.prometheus.enable = true;
          }

          {
            is = t.lb;
            nixos =
              { select, ... }:
              let
                webs = select t.web;
              in
              {
                services.haproxy.backends = map (w: w.addr) webs;
              };
          }

          {
            is = t.user;
            nixos =
              { user, ... }:
              {
                users.users.${user.name}.openssh.authorizedKeys.keys = user.sshKeys;
              };
          }

          {
            is = [
              t.host
              (t.has t.admin)
            ];
            nixos.security.sudo.enable = true;
          }
        ];

        # assertions (multi-check via attrset)
        # lb has lb→server→nginx/ssh/firewall + monitoring via neededBy
        # web-1 has host→nix rules, sudo (has admin child), alice keys
        expr = {
          lb-nginx = lb.services.nginx.enable;
          lb-ssh = lb.services.openssh.enable;
          lb-firewall = lb.networking.firewall.enable;
          lb-prometheus = lb.services.prometheus.enable;
          lb-haproxy = lb.services.haproxy.backends;
          web1-nix = web-1.nix.settings.experimental-features;
          web1-sudo = web-1.security.sudo.enable;
          alice-keys = web-1.users.users.alice.openssh.authorizedKeys.keys;
        };
        expected = {
          lb-nginx = true;
          lb-ssh = true;
          lb-firewall = true;
          lb-prometheus = true;
          lb-haproxy = [
            "10.0.0.2"
            "10.0.0.3"
          ];
          web1-nix = [
            "nix-command"
            "flakes"
          ];
          web1-sudo = true;
          alice-keys = [ "ssh-ed25519 abc" ];
        };
      }
    );
  };
}
