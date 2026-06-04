nest:
let
  inherit (nest) injectNames traverseDom;

  rawTraits = {
    host = {
      class = {
        nixos = _: _: { };
      };
    };
    user = {
      class = {
        nixos = _: _: { };
      };
    };
    admin = { };
  };
  t = injectNames rawTraits;

  dom = {
    prod = {
      web-1 = {
        is = [ t.host ];
        system = "x86_64-linux";
      };
      web-2 = {
        is = [ t.host ];
        system = "x86_64-linux";
      };
    };
    prod2.web-1 = {
      is = [ t.host ];
      system = "x86_64-linux";
      users.alice = {
        is = [
          t.user
          t.admin
        ];
        sshKeys = [ "ssh-ed25519 abc" ];
      };
    };
  };

  nodes = traverseDom dom;
  byName = name: builtins.head (builtins.filter (n: n.name == name) nodes);
in
{
  dom = {
    test-finds-root-nodes = {
      expr = builtins.length nodes;
      expected = 4; # prod.web-1, prod.web-2, prod2.web-1, prod2.web-1.users.alice
    };
    test-node-has-name = {
      expr = (byName "web-1").name;
      expected = "web-1";
    };
    test-node-has-user-fields = {
      expr = (byName "web-1").system;
      expected = "x86_64-linux";
    };
    test-node-has-path = {
      expr = (byName "web-1").__path;
      expected = [
        "prod"
        "web-1"
      ];
    };
    test-child-parent-path = {
      expr = (byName "alice").__parentPath;
      expected = [
        "prod2"
        "web-1"
      ];
    };
    test-namespace-ignored = {
      # "prod" and "users" have no `is` → not nodes
      expr = builtins.length (builtins.filter (n: n.name == "prod" || n.name == "users") nodes);
      expected = 0;
    };

    # Marker-only nodes (no class trait) are in the DOM and findable by select
    test-marker-only-node-in-dom = {
      expr =
        let
          domWithMarker = {
            registry.sentinel = {
              is = [ t.admin ]; # admin has no class
            };
            prod.web = {
              is = [ t.host ];
              system = "x86_64-linux";
            };
          };
          ns = traverseDom domWithMarker;
          webNode = builtins.head (builtins.filter (n: n.name == "web") ns);
          ctx = nest.mkCtx webNode ns;
        in
        builtins.length (ctx.select t.admin); # select must find sentinel
      expected = 1;
    };

    # Namespace attrs are inherited by child nodes
    test-namespace-attr-inherited = {
      expr = (byName "web-1").system;
      expected = "x86_64-linux";
    };

    # Nested nodes inherit scalar namespace attrs from a parent DOM node
    test-nested-node-inherits-system = {
      expr =
        let
          domWithUser = {
            prod = {
              system = "x86_64-linux";
              web = {
                is = [ t.host ];
                users.alice = {
                  is = [ t.user ];
                };
              };
            };
          };
          ns = traverseDom domWithUser;
          alice = builtins.head (builtins.filter (n: n.name == "alice") ns);
        in
        alice.system == "x86_64-linux" && builtins.length alice.is == 1;
      expected = true;
    };

    # Non-attrset namespace attrs flow down to child nodes
    test-namespace-scalar-inherited = {
      expr =
        let
          domWithEnv = {
            prod = {
              env = "prod";
              web = {
                is = [ t.host ];
                system = "x86_64-linux";
              };
            };
          };
          ns = traverseDom domWithEnv;
          web = builtins.head (builtins.filter (n: n.name == "web") ns);
        in
        web.env;
      expected = "prod";
    };

    # Node own attr overrides inherited namespace attr
    test-node-attr-overrides-namespace = {
      expr =
        let
          domWithOverride = {
            prod = {
              env = "prod";
              web = {
                is = [ t.host ];
                system = "x86_64-linux";
                env = "staging";
              };
            };
          };
          ns = traverseDom domWithOverride;
          web = builtins.head (builtins.filter (n: n.name == "web") ns);
        in
        web.env;
      expected = "staging";
    };

    # mkCtx select.siblings: peers sharing the same __parentPath
    # prod.web-1, prod.web-2, prod2.web-1 all have __parentPath=null (namespace, not DOM node)
    test-select-siblings = {
      expr =
        let
          ctx = nest.mkCtx (byName "web-1") nodes;
          sibs = ctx.select.siblings t.host;
        in
        builtins.length sibs;
      expected = 2; # prod.web-2 and prod2.web-1 share __parentPath=null
    };

    # mkCtx select.children: direct DOM children (parentPath == node.__path)
    test-select-children = {
      expr =
        let
          # prod2.web-1 is the node with alice as a DOM child
          web1prod2 = builtins.head (
            builtins.filter (
              n:
              n.__path == [
                "prod2"
                "web-1"
              ]
            ) nodes
          );
          ctx = nest.mkCtx web1prod2 nodes;
        in
        builtins.length (ctx.select.children t.user);
      expected = 1; # prod2.web-1.users.alice
    };

    # Deep namespace nesting: when ALL ancestors are wrappers (no `is`),
    # the node is a root — __parentPath is null, __path keeps every level.
    test-deep-namespace-parent-is-root = {
      expr =
        let
          ns = traverseDom {
            region.us.prod.web = {
              is = [ t.host ];
              system = "x86_64-linux";
            };
          };
          web = builtins.head ns;
        in
        {
          inherit (web) __path __parentPath;
        };
      expected = {
        __path = [
          "region"
          "us"
          "prod"
          "web"
        ];
        __parentPath = null;
      };
    };
  };
}
