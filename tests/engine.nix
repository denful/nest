nest:
let
  inherit (nest) nestTest;
in
{
  engine = {

    # Basic: server rule fires on server node
    test-nginx-on-server = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.server = { };
        nest.prod.web = {
          is = [
            nest.host
            nest.server
          ];
          system = "x86_64-linux";
        };
        nest.rules = with nest; [
          {
            is = server;
            nixos.services.nginx.enable = true;
          }
        ];
        expr = web.services.nginx.enable;
        expected = true;
      }
    );

    # Rule fn uses select.node for current node
    test-user-ssh-keys = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ nest.user ];
          sshKeys = [ "ssh-ed25519 abc" ];
        };
        nest.rules = with nest; [
          {
            is = user;
            nixos =
              { select, ... }:
              {
                users.users.${select.node.name}.openssh.authorizedKeys.keys = select.node.sshKeys;
              };
          }
        ];
        expr = web.users.users.alice.openssh.authorizedKeys.keys;
        expected = [ "ssh-ed25519 abc" ];
      }
    );

    test-css-descendant-selector-in-rule = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ nest.user ];
          sshKeys = [ "ssh-ed25519 abc" ];
        };
        nest.rules = with nest; [
          {
            is = ".nixos user";
            nixos =
              { select, ... }:
              {
                users.users.${select.node.name}.openssh.authorizedKeys.keys = select.node.sshKeys;
              };
          }
        ];
        expr = web.users.users.alice.openssh.authorizedKeys.keys;
        expected = [ "ssh-ed25519 abc" ];
      }
    );

    # needs expansion: server → nginx → nginx rule fires
    test-needs-expansion = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.nginx = { };
        nest.trait.server.needs = [ nest.nginx ];
        nest.prod.web = {
          is = [
            nest.host
            nest.server
          ];
          system = "x86_64-linux";
        };
        nest.rules = with nest; [
          {
            is = nginx;
            nixos.services.nginx.enable = true;
          }
        ];
        expr = web.services.nginx.enable;
        expected = true;
      }
    );

    # id selector
    test-id-selector = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules = [
          {
            is = "web";
            nixos.networking.hostName = "web";
          }
        ];
        expr = web.networking.hostName;
        expected = "web";
      }
    );

    # select in rule fn
    test-select-in-rule = nestTest (
      { nest, lb, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.web = { };
        nest.trait.lb = { };
        nest.prod.lb = {
          is = [
            t.host
            t.lb
          ];
          system = "x86_64-linux";
        };
        nest.prod.web1 = {
          is = [
            t.host
            t.web
          ];
          system = "x86_64-linux";
          addr = "10.0.0.2";
          port = 80;
        };
        nest.prod.web2 = {
          is = [
            t.host
            t.web
          ];
          system = "x86_64-linux";
          addr = "10.0.0.3";
          port = 80;
        };
        nest.rules = [
          {
            is = t.lb;
            nixos =
              { select, ... }:
              {
                services.haproxy.backends = map (w: w.addr) (select t.web);
              };
          }
        ];
        expr = lb.services.haproxy.backends;
        expected = [
          "10.0.0.2"
          "10.0.0.3"
        ];
      }
    );

    # callWithArgs injects current node when an arg matches the node's trait name
    test-callWithArgs-entity-args = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ nest.user ];
        };
        nest.rules = with nest; [
          {
            is = user;
            nixos =
              { user, ... }:
              {
                users.users.${user.name}.description = user.name;
              };
          }
        ];
        expr = web.users.users.alice.description;
        expected = "alice";
      }
    );

    # neededBy: monitoring injected into server nodes
    test-neededby = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.server = { };
        nest.trait.monitoring.neededBy = t.server;
        nest.prod.web = {
          is = [
            t.host
            t.server
          ];
          system = "x86_64-linux";
        };
        nest.rules = [
          {
            is = t.monitoring;
            nixos.services.prometheus.enable = true;
          }
        ];
        expr = web.services.prometheus.enable;
        expected = true;
      }
    );

    # neededBy traits with needs should still expand their dependencies
    test-neededby-expands-needs = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.server = { };
        nest.trait.niri = { };
        nest.trait.foo = {
          needs = [ t.niri ];
          neededBy = t.server;
        };
        nest.prod.web = {
          is = [
            t.host
            t.server
          ];
          system = "x86_64-linux";
        };
        nest.rules = [
          {
            is = t.host;
            nixos =
              { select, ... }:
              {
                niriPresent = builtins.elem t.niri select.node.is;
              };
          }
        ];
        expr = web.niriPresent;
        expected = true;
      }
    );

    # has/within selectors; class fns use select.node
    test-has-selector = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user = {
          class.nixos = _select: modules: { nixos = modules; };
          class.user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.admin = { };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [
            t.user
            t.admin
          ];
        };
        nest.rules = [
          {
            is = [
              t.host
              (t.has t.admin)
            ];
            nixos.security.sudo.enable = true;
          }
        ];
        expr = web.security.sudo.enable;
        expected = true;
      }
    );

    # inherited attrs: namespace attr flows top-down, accessible via select.node in rule fn
    test-inherited-attrs = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod = {
          env = "prod";
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules = with nest; [
          {
            is = host;
            nixos =
              { select, ... }:
              {
                envName = select.node.env;
              };
          }
        ];
        expr = web.envName;
        expected = "prod";
      }
    );

    # inherited attrs: node own attr wins over namespace attr
    test-inherited-attrs-override = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod = {
          env = "prod";
          region = "us-east";
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
          env = "staging";
        };
        nest.rules = with nest; [
          {
            is = host;
            nixos =
              { select, ... }:
              {
                inherit (select.node) env region;
              };
          }
        ];
        expr = { inherit (web) env region; };
        expected = {
          env = "staging";
          region = "us-east";
        };
      }
    );

    test-inherited-attrs-selector = nestTest (
      {
        nest,
        web,
        staging,
        ...
      }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod = {
          env = "prod";
        };
        nest.staging-ns = {
          env = "staging";
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.staging-ns.staging = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules = with nest; [
          {
            is = attrs { env = "prod"; };
            nixos.services.monitoring.enable = true;
          }
        ];
        expr = {
          webMonitoring = web.services.monitoring.enable;
          stagingMonitoring = staging.services.monitoring.enable or false;
        };
        expected = {
          webMonitoring = true;
          stagingMonitoring = false;
        };
      }
    );

    # synthetic attrs: trait.synth = select: { ... }; accessible via select.node in rule fn
    test-synth-attr = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.host.synth = select: {
          node.userCount = builtins.length (select.children t.user);
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.prod.web.users.bob = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = t.host;
            nixos =
              { select, ... }:
              {
                inherit (select.node) userCount;
              };
          }
        ];
        expr = web.userCount;
        expected = 2;
      }
    );

    test-synth-attr-selector = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.host.synth = select: {
          node.userCount = builtins.length (select.children t.user);
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = [
              t.host
              (t.attrs { userCount = 1; })
            ];
            nixos.security.sudo.enable = true;
          }
        ];
        expr = web.security.sudo.enable;
        expected = true;
      }
    );

    # select.parent in rule fn
    test-select-parent = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = t.user;
            user =
              { select, ... }:
              let
                parentHost = select.parent t.host;
              in
              {
                parentSystem = parentHost.system;
              };
          }
        ];
        expr = web.users.users.alice.parentSystem;
        expected = "x86_64-linux";
      }
    );

    # select.parents in rule fn (all ancestor hosts)
    test-select-parents = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = t.user;
            user =
              { select, ... }:
              {
                ancestorCount = builtins.length (select.parents t.host);
              };
          }
        ];
        expr = web.users.users.alice.ancestorCount;
        expected = 1;
      }
    );

    # select.within in rule fn (descendants of a specific node)
    test-select-within = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.prod.web.users.bob = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = t.host;
            nixos =
              { select, host, ... }:
              {
                userCount = builtins.length (select.within host t.user);
              };
          }
        ];
        expr = web.userCount;
        expected = 2;
      }
    );

    # within selector in rule: user node has host as DOM ancestor
    test-within-selector = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.prod.web.users.alice = {
          is = [ t.user ];
        };
        nest.rules = [
          {
            is = [
              t.user
              (t.within t.host)
            ];
            user = _: {
              withinHost = true;
            };
          }
        ];
        expr = web.users.users.alice.withinHost;
        expected = true;
      }
    );

    # trait synth producing virtual children (synth.node.children)
    test-trait-synth-children = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.admin = { };
        # Synth injects virtual user children from global admin nodes.
        # Marker-only nodes are now in the DOM so select can find them.
        nest.trait.host.synth = select: {
          node.children = map (u: {
            inherit (u) name;
            is = [ t.user ];
          }) (select t.admin);
        };
        nest.users.alice = {
          is = [ t.admin ];
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.rules = [
          {
            is = t.user;
            user = _: {
              isNormalUser = true;
            };
          }
        ];
        expr = web.users.users.alice.isNormalUser;
        expected = true;
      }
    );

    # rule synth producing virtual node attrs (visible to class fn via select.node)
    test-rule-synth-node-attr = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        # class fn reads synth-derived attr from select.node
        nest.trait.host.class.nixos =
          select: modules: (nest.testMerge modules) // { tier = select.node.tier or "unknown"; };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.rules = [
          {
            is = t.host;
            synth = _: {
              node.tier = "frontend";
            };
          }
        ];
        expr = web.tier;
        expected = "frontend";
      }
    );

    # rule synth producing virtual children (rule synth mirrors trait synth)
    test-rule-synth-children = nestTest (
      { nest, web, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.admin = { };
        nest.users.alice = {
          is = [ t.admin ];
          sshKeys = [ "ssh-ed25519 abc" ];
        };
        nest.prod.web = {
          is = [ t.host ];
          system = "x86_64-linux";
        };
        nest.rules = [
          # Rule synth: inject user children from global admin nodes
          {
            is = t.host;
            synth =
              { select, ... }:
              {
                node.children = map (u: {
                  inherit (u) name sshKeys;
                  is = [ t.user ];
                }) (select t.admin);
              };
          }
          {
            is = t.user;
            user =
              { user, ... }:
              {
                isNormalUser = true;
                openssh.authorizedKeys.keys = user.sshKeys;
              };
          }
        ];
        expr = web.users.users.alice.openssh.authorizedKeys.keys;
        expected = [ "ssh-ed25519 abc" ];
      }
    );

    # select.siblings
    test-select-siblings = nestTest (
      { nest, lb, ... }:
      let
        t = nest;
      in
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.web = { };
        nest.trait.lb = { };
        nest.prod.lb = {
          is = [
            t.host
            t.lb
          ];
        };
        nest.prod.web1 = {
          is = [
            t.host
            t.web
          ];
        };
        nest.prod.web2 = {
          is = [
            t.host
            t.web
          ];
        };
        nest.rules = [
          {
            is = t.lb;
            nixos =
              { select, ... }:
              {
                webCount = builtins.length (select.siblings t.web);
              };
          }
        ];
        expr = lb.webCount;
        expected = 2;
      }
    );

    # --- attrset rules syntax ---

    # attrset rule: bare name selector as key
    test-attrset-rule-name-sel = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules."web" = {
          nixos.services.nginx.enable = true;
        };
        expr = web.services.nginx.enable;
        expected = true;
      }
    );

    # attrset rule: star selector as key
    test-attrset-rule-star-sel = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules."*" = {
          nixos.services.sshd.enable = true;
        };
        expr = web.services.sshd.enable;
        expected = true;
      }
    );

    # attrset rule: class selector as key
    test-attrset-rule-class-sel = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.server = { };
        nest.prod.web = {
          is = [
            nest.host
            nest.server
          ];
          system = "x86_64-linux";
        };
        nest.prod.db = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules.".nixos" = {
          nixos.x = 42;
        };
        expr = web.x;
        expected = 42;
      }
    );

    # attrset rule: attribute selector as key
    test-attrset-rule-child-sel = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
          role = "frontend";
        };
        nest.prod.db = {
          is = [ nest.host ];
          system = "x86_64-linux";
          role = "backend";
        };
        nest.rules."[role=frontend]" = {
          nixos.services.nginx.enable = true;
        };
        expr = web.services.nginx.enable;
        expected = true;
      }
    );

    # attrset rules: multiple keys, all applied
    test-attrset-rule-multiple-keys = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules = {
          "web" = {
            nixos.x = 1;
          };
          "*" = {
            nixos.y = 2;
          };
        };
        expr = web.x + web.y;
        expected = 3;
      }
    );

    # label-keyed attrset rule: the key is an arbitrary label, the selector
    # lives in `is`. (This is what lets rules split across import-tree files —
    # distinct labels merge where list defs would not.) The label "anyLabel"
    # must NOT act as a selector, or web (name "web") would not match.
    test-attrset-rule-label-is = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules.anyLabel = {
          is = nest.host;
          nixos.tagged = true;
        };
        expr = web.tagged;
        expected = true;
      }
    );

    # attrset rules: mix list and attrset in evalNest (not module system — direct attrset only)
    test-attrset-rule-id-sel = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
        };
        nest.rules."#web" = {
          nixos.services.sshd.enable = true;
        };
        expr = web.services.sshd.enable;
        expected = true;
      }
    );

    # nested DOM node: is = [ "user" ] (list with CSS name selector)
    test-nested-node-is-list-css-selector = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
          users.vic = {
            is = [ "user" ];
          };
        };
        nest.rules = with nest; [
          {
            is = user;
            nixos.users.users.vic.description = "vic";
          }
        ];
        expr = web.users.users.vic.description;
        expected = "vic";
      }
    );

    # nested DOM node: is = "user" (bare CSS string, not a list)
    test-nested-node-is-bare-css-selector = nestTest (
      { nest, web, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.prod.web = {
          is = [ nest.host ];
          system = "x86_64-linux";
          users.vic = {
            is = "user";
          };
        };
        nest.rules = with nest; [
          {
            is = user;
            nixos.users.users.vic.description = "vic";
          }
        ];
        expr = web.users.users.vic.description;
        expected = "vic";
      }
    );

    # mirrors vtx dom.nix: both top-level and nested nodes use bare CSS string is
    test-vtx-dom-bare-is-both-levels = nestTest (
      { nest, bilbo, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.bilbo = {
          is = "host";
          system = "x86_64-linux";
          vic = {
            is = "user";
          };
        };
        nest.rules = with nest; [
          {
            is = user;
            nixos.users.users.vic.description = "vic-on-bilbo";
          }
        ];
        expr = bilbo.users.users.vic.description;
        expected = "vic-on-bilbo";
      }
    );

    # neededBy with descendant selector on nodes whose is= uses bare CSS strings
    # mirrors vtx: vic-user.neededBy = "host user#vic" (descendant combinator)
    test-neededby-descendant-selector-bare-is = nestTest (
      { nest, bilbo, ... }:
      {
        nest.trait.host.class.nixos = _select: modules: nest.testMerge modules;
        nest.trait.user.class = {
          nixos = _select: modules: { nixos = modules; };
          user = select: modules: {
            nixos = [ { users.users.${select.node.name} = nest.testMerge modules; } ];
          };
        };
        nest.trait.admin = {
          neededBy = "host user#vic";
        };
        nest.bilbo = {
          is = "host";
          system = "x86_64-linux";
          vic = {
            is = "user";
          };
        };
        nest.rules = with nest; [
          {
            is = admin;
            user.extraGroups = [ "wheel" ];
          }
        ];
        expr = bilbo.users.users.vic.extraGroups;
        expected = [ "wheel" ];
      }
    );

  };
}
