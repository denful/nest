# CSS rules: selectors → NixOS config fragments.
#
# Cross-host data sharing via select (akin to Den pipe.collect):
#   lb rule    — select.siblings web  → haproxy backends (same env only)
#   host rule  — select.siblings host → /etc/hosts peers (same env only)
{ nest, lib, ... }:
let
  mkHaproxyConfig =
    backends:
    lib.concatStringsSep "\n" (
      [
        "frontend http-in"
        "  bind *:80"
        "  default_backend webservers"
        ""
        "backend webservers"
        "  balance roundrobin"
      ]
      ++ lib.imap1 (i: b: "  server backend${toString i} ${b.addr}:${toString b.port} check") backends
    );

in
{
  nest.rules = [

    # --- host defaults ---
    {
      is = nest.host;
      nixos =
        { host, ... }:
        {
          networking.hostName = host.name;
          system.stateVersion = "25.11";
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          # minimal boot/fs config — override in production
          boot.loader.grub.enable = false;
          fileSystems."/".device = "/dev/fake";
          fileSystems."/".fsType = "auto";
        };
    }

    # --- trait-driven services ---
    {
      is = nest.nginx;
      nixos.services.nginx.enable = true;
      nixos.services.nginx.virtualHosts.default = {
        default = true;
        root = "/var/www";
      };
    }
    {
      is = nest.ssh;
      nixos.services.openssh.enable = true;
    }
    {
      is = nest.firewall;
      nixos.networking.firewall.enable = true;
    }

    # monitoring auto-injected via neededBy = server
    {
      is = nest.monitoring;
      nixos.services.prometheus.exporters.node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    }

    # --- lb: haproxy from sibling web nodes ---
    # select.siblings web peers in same env
    {
      is = nest.lb;
      nixos =
        { select, ... }:
        let
          webs = select.siblings nest.web;
        in
        {
          services.haproxy.enable = true;
          services.haproxy.config = mkHaproxyConfig (
            map (w: {
              inherit (w) addr;
              port = w.httpPort;
            }) webs
          );
        };
    }

    # --- /etc/hosts from sibling hosts ---
    # each host gets entries for all peers in same environment
    {
      is = nest.host;
      nixos =
        { select, ... }:
        let
          peers = select.siblings nest.host;
        in
        {
          networking.extraHosts = lib.concatMapStringsSep "\n" (p: "${p.addr} ${p.name}") peers;
        };
    }

    # --- user synth: rules inject virtual user children per host based on env ---
    # Registry nodes (nest.users.*) carry nest.user + role marker.
    # select finds them; synth copies name+sshKeys into children under each host.

    # prod: admin users only
    {
      is = [
        nest.host
        (nest.attrs { env = "prod"; })
      ];
      synth =
        { select, ... }:
        {
          node.children = map (u: {
            inherit (u) name sshKeys;
            is = [
              nest.user
              nest.admin
            ];
          }) (select nest.admin);
        };
    }

    # staging: admin + deploy users
    {
      is = [
        nest.host
        (nest.attrs { env = "staging"; })
      ];
      synth =
        { select, ... }:
        {
          node.children =
            map (u: {
              inherit (u) name sshKeys;
              is = [
                nest.user
                nest.admin
              ];
            }) (select nest.admin)
            ++ map (u: {
              inherit (u) name sshKeys;
              is = [
                nest.user
                nest.deploy
              ];
            }) (select nest.deploy);
        };
    }

    # --- user rules: fire on synthesized children, not registry entries ---

    {
      is = nest.user;
      user =
        { user, ... }:
        {
          isNormalUser = true;
          openssh.authorizedKeys.keys = user.sshKeys;
        };
    }

    {
      is = nest.admin;
      user.extraGroups = [ "wheel" ];
    }

    # sudo on prod + staging (all envs that receive admin users)
    {
      is = [
        nest.host
        (nest.or [
          (nest.attrs { env = "prod"; })
          (nest.attrs { env = "staging"; })
        ])
      ];
      nixos.security.sudo.wheelNeedsPassword = false;
    }

  ];
}
