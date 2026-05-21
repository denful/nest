nest:
let
  inherit (nest)
    matchesOne
    mkCtx
    mkSelectors
    makeNode
    emptyCtx
    ;
  sel = mkSelectors;

  traitServer = {
    __path = [ "server" ];
  };
  traitHost = {
    __path = [ "host" ];
    class = {
      nixos = _: _: null;
    };
  };
  traitFoo = {
    __path = [ "foo" ];
    class = {
      foo = _: _: null;
    };
  };
  traitBar = {
    __path = [ "bar" ];
    class = {
      bar = _: _: null;
    };
  };
  traitFooBar = {
    __path = [ "foo" ];
    class = {
      foo = _: _: null;
      bar = _: _: null;
    };
  };
  traitAdmin = {
    __path = [ "admin" ];
  };

  webNode = makeNode "web" [ traitHost traitServer ] { system = "x86_64-linux"; };
  adminUser = makeNode "alice" [ traitAdmin ] { };
  allNodes = [
    webNode
    adminUser
  ];

  # Hierarchy for child/descendant combinator tests
  clusterNode = {
    name = "cluster";
    is = [ ];
    __path = [ "cluster" ];
    __parentPath = null;
  };
  memberNode = {
    name = "web";
    is = [ traitServer ];
    __path = [
      "cluster"
      "web"
    ];
    __parentPath = [ "cluster" ];
    system = "x86_64-linux";
  };
  otherMemberNode = {
    name = "other";
    is = [ traitServer ];
    __path = [
      "cluster"
      "other"
    ];
    __parentPath = [ "cluster" ];
    system = "x86_64-linux";
  };
  hierarchyNodes = [
    clusterNode
    memberNode
    otherMemberNode
  ];
  memberCtx = mkCtx memberNode hierarchyNodes;
  otherMemberCtx = mkCtx otherMemberNode hierarchyNodes;
in
{
  selectors = {
    test-trait-match = {
      expr = matchesOne webNode traitServer (emptyCtx webNode allNodes);
      expected = true;
    };
    test-trait-no-match = {
      expr = matchesOne webNode traitAdmin (emptyCtx webNode allNodes);
      expected = false;
    };
    # explicit #id selector
    test-id-match = {
      expr = matchesOne webNode "#web" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-id-no-match = {
      expr = matchesOne webNode "#other" (emptyCtx webNode allNodes);
      expected = false;
    };
    # bare name = type selector (also matches by name)
    test-type-match = {
      expr = matchesOne webNode "web" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-star = {
      expr = matchesOne webNode sel.star (emptyCtx webNode allNodes);
      expected = true;
    };
    test-attrs-match = {
      expr = matchesOne webNode (sel.attrs { system = "x86_64-linux"; }) (emptyCtx webNode allNodes);
      expected = true;
    };
    test-attrs-no-match = {
      expr = matchesOne webNode (sel.attrs { system = "aarch64-linux"; }) (emptyCtx webNode allNodes);
      expected = false;
    };
    test-attrs-bool-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            enabled = true;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node (sel.attrs { enabled = true; }) ctx;
      expected = true;
    };
    test-attrs-bool-no-match-string = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            enabled = "true";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node (sel.attrs { enabled = true; }) ctx;
      expected = false;
    };
    test-or-match = {
      expr = matchesOne webNode (sel.or [
        traitAdmin
        traitServer
      ]) (emptyCtx webNode allNodes);
      expected = true;
    };
    test-not-match = {
      expr = matchesOne webNode (sel.not traitAdmin) (emptyCtx webNode allNodes);
      expected = true;
    };
    test-not-no-match = {
      expr = matchesOne webNode (sel.not traitServer) (emptyCtx webNode allNodes);
      expected = false;
    };
    test-compound-and-match = {
      expr = matchesOne webNode [ traitHost traitServer ] (emptyCtx webNode allNodes);
      expected = true;
    };
    test-compound-and-no-match = {
      expr = matchesOne webNode [ traitHost traitAdmin ] (emptyCtx webNode allNodes);
      expected = false;
    };
    test-class-match = {
      expr = matchesOne webNode (sel.class "nixos") (emptyCtx webNode allNodes);
      expected = true;
    };
    test-class-no-match = {
      expr = matchesOne webNode (sel.class "homeManager") (emptyCtx webNode allNodes);
      expected = false;
    };

    test-current-node-selector = {
      expr = matchesOne webNode "&.class" (emptyCtx webNode allNodes);
      expected = false;
    };
    test-current-node-selector-class = {
      expr = matchesOne webNode "&.nixos" (emptyCtx webNode allNodes);
      expected = true;
    };

    # CSS string selector tests
    test-css-star = {
      expr = matchesOne webNode "*" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-class-match = {
      expr = matchesOne webNode ".nixos" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-class-no-match = {
      expr = matchesOne webNode ".homeManager" (emptyCtx webNode allNodes);
      expected = false;
    };
    test-css-attr-match = {
      expr = matchesOne webNode "[system=x86_64-linux]" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-attr-no-match = {
      expr = matchesOne webNode "[system=aarch64-linux]" (emptyCtx webNode allNodes);
      expected = false;
    };
    test-css-attr-true-string-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = "true";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=true]" ctx;
      expected = true;
    };
    test-css-attr-true-bool-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = true;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=true]" ctx;
      expected = true;
    };
    test-css-attr-false-string-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = "false";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=false]" ctx;
      expected = true;
    };
    test-css-attr-false-bool-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = false;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=false]" ctx;
      expected = true;
    };

    # === BOOLEAN ATTRIBUTE EDGE CASES ===
    test-css-attr-true-no-match-false-bool = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = false;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=true]" ctx;
      expected = false;
    };
    test-css-attr-true-no-match-false-string = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = "false";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=true]" ctx;
      expected = false;
    };
    test-css-attr-false-no-match-true-bool = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = true;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=false]" ctx;
      expected = false;
    };
    test-css-attr-false-no-match-true-string = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = "true";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=false]" ctx;
      expected = false;
    };
    test-css-attr-true-match-1-int = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = 1;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=1]" ctx;
      expected = true;
    };
    test-css-attr-false-match-0-int = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            foo = 0;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[foo=0]" ctx;
      expected = true;
    };
    test-css-attrExists-match = {
      expr = matchesOne webNode "[system]" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-attrExists-no-match = {
      expr = matchesOne webNode "[missing]" (emptyCtx webNode allNodes);
      expected = false;
    };
    # compound: #id.class
    test-css-compound-id-class = {
      expr = matchesOne webNode "#web.nixos" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-admin-user-suffix-match = {
      expr =
        let
          traitHostAdmin = {
            __path = [
              "host"
              "admin"
            ];
          };
          traitHostUser = {
            __path = [
              "host"
              "user"
            ];
            class = {
              user = _: _: null;
            };
          };
          hostNode = {
            name = "host";
            is = [ ];
            __path = [ "host" ];
            __parentPath = null;
          };
          userNode = {
            name = "tux";
            is = [
              traitHostAdmin
              traitHostUser
            ];
            __path = [
              "host"
              "tux"
            ];
            __parentPath = [ "host" ];
          };
          ctx = mkCtx userNode [
            hostNode
            userNode
          ];
        in
        matchesOne userNode "admin.user" ctx;
      expected = true;
    };
    test-css-host-admin-user-descendant-match = {
      expr =
        let
          traitHostAdmin = {
            __path = [
              "host"
              "admin"
            ];
          };
          traitHostUser = {
            __path = [
              "host"
              "user"
            ];
            class = {
              user = _: _: null;
            };
          };
          hostNode = {
            name = "host";
            is = [ ];
            __path = [ "host" ];
            __parentPath = null;
          };
          userNode = {
            name = "tux";
            is = [
              traitHostAdmin
              traitHostUser
            ];
            __path = [
              "host"
              "tux"
            ];
            __parentPath = [ "host" ];
          };
          ctx = mkCtx userNode [
            hostNode
            userNode
          ];
        in
        matchesOne userNode "host admin.user" ctx;
      expected = true;
    };
    # compound: multiple attrs [a=1][b=2]
    test-css-compound-attrs = {
      expr = matchesOne memberNode "[system=x86_64-linux]" memberCtx;
      expected = true;
    };
    # or grouping via comma
    test-css-or-string = {
      expr = matchesOne webNode "#web, #alice" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-or-string-no-match = {
      expr = matchesOne webNode "#other, #missing" (emptyCtx webNode allNodes);
      expected = false;
    };
    # :not() pseudo
    test-css-not-string = {
      expr = matchesOne webNode ":not(#alice)" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-paren-dot-same-as-dot = {
      expr =
        let
          node = makeNode "x" [ traitFooBar ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(.foo).bar" ctx == matchesOne node ".foo.bar" ctx;
      expected = true;
    };
    test-css-dot-paren-same-as-dot = {
      expr =
        let
          node = makeNode "x" [ traitFooBar ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ".foo(.bar)" ctx == matchesOne node ".foo.bar" ctx;
      expected = true;
    };
    test-css-paren-adjacent-same-as-dot = {
      expr =
        let
          node = makeNode "x" [ traitFooBar ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(.foo)(.bar)" ctx == matchesOne node ".foo.bar" ctx;
      expected = true;
    };
    test-css-paren-descendant-same-as-dot-descendant = {
      expr =
        let
          parent = makeNode "parent" [ traitFoo ] { };
          child = {
            name = "child";
            is = [ traitBar ];
            __path = [
              "parent"
              "child"
            ];
            __parentPath = [ "parent" ];
          };
          ctx = mkCtx child [
            parent
            child
          ];
        in
        matchesOne child "(.foo) .bar" ctx == matchesOne child ".foo .bar" ctx;
      expected = true;
    };
    test-css-name-paren-equals-list = {
      expr =
        let
          node = makeNode "x" [ traitFoo traitBar ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "foo(bar)" ctx == matchesOne node [ traitFoo traitBar ] ctx;
      expected = true;
    };
    test-css-paren-and-match = {
      expr = matchesOne webNode "(server)(host)" (emptyCtx webNode allNodes);
      expected = true;
    };
    test-css-paren-and-no-match = {
      expr = matchesOne webNode "(server)(admin)" (emptyCtx webNode allNodes);
      expected = false;
    };
    # child combinator: cluster > web
    test-css-child-match = {
      expr = matchesOne memberNode "cluster > web" memberCtx;
      expected = true;
    };
    test-css-child-no-match = {
      expr = matchesOne memberNode "other > web" memberCtx;
      expected = false;
    };
    # descendant combinator: cluster web
    test-css-descendant-match = {
      expr = matchesOne memberNode "cluster web" memberCtx;
      expected = true;
    };
    test-css-descendant-no-match = {
      expr = matchesOne memberNode "other web" memberCtx;
      expected = false;
    };
    test-css-selector-descendant-class-name = {
      expr =
        let
          traitUser = {
            __path = [ "user" ];
          };
          hostNode = {
            name = "host";
            __path = [ "host" ];
            __parentPath = null;
            is = [ traitHost ];
          };
          userNode = {
            name = "tux";
            __path = [
              "host"
              "tux"
            ];
            __parentPath = [ "host" ];
            is = [ traitUser ];
          };
          ctx = mkCtx userNode [
            hostNode
            userNode
          ];
        in
        matchesOne userNode ".nixos user" ctx;
      expected = true;
    };
    test-css-descendant-with-compound-class = {
      expr =
        let
          traitYZ = {
            __path = [ "yz" ];
            class = {
              y = _: _: null;
              z = _: _: null;
            };
          };
          xNode = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
          };
          childNode = {
            name = "child";
            __path = [
              "x"
              "child"
            ];
            __parentPath = [ "x" ];
            is = [ traitYZ ];
          };
          ctx = mkCtx childNode [
            xNode
            childNode
          ];
        in
        matchesOne childNode "x .y.z" ctx;
      expected = true;
    };
    test-css-adjacent-sibling-match = {
      expr = matchesOne otherMemberNode "web + other" otherMemberCtx;
      expected = true;
    };
    test-css-adjacent-sibling-no-match = {
      expr = matchesOne memberNode "other + web" memberCtx;
      expected = false;
    };
    # Adjacent sibling: both prev AND current must match selectors
    test-css-adjacent-sibling-both-match = {
      expr =
        let
          prev = {
            name = "web";
            is = [ traitServer ];
            __path = [
              "cluster"
              "web"
            ];
            __parentPath = [ "cluster" ];
          };
          curr = {
            name = "other";
            is = [ traitServer ];
            __path = [
              "cluster"
              "other"
            ];
            __parentPath = [ "cluster" ];
          };
          ctx = mkCtx curr [
            clusterNode
            prev
            curr
          ];
        in
        matchesOne curr "#web + #other" ctx;
      expected = true;
    };
    # Adjacent with selector that doesn't match current node
    test-css-adjacent-sibling-curr-no-match = {
      expr =
        let
          prev = {
            name = "web";
            is = [ traitServer ];
            __path = [
              "cluster"
              "web"
            ];
            __parentPath = [ "cluster" ];
          };
          curr = {
            name = "other";
            is = [ ];
            __path = [
              "cluster"
              "other"
            ];
            __parentPath = [ "cluster" ];
          };
          ctx = mkCtx curr [
            clusterNode
            prev
            curr
          ];
        in
        matchesOne curr "#web + #notexist" ctx;
      expected = false;
    };
    test-css-has-descendant-match = {
      expr = matchesOne clusterNode "&:has(web)" (mkCtx clusterNode hierarchyNodes);
      expected = true;
    };
    test-css-has-descendant-no-match = {
      expr = matchesOne memberNode "&:has(other)" memberCtx;
      expected = false;
    };
    test-css-has-class-descendant = {
      expr =
        let
          traitHome = {
            __path = [ "home" ];
            class = {
              homeManager = _: _: null;
            };
          };
          hostNode = {
            name = "host";
            __path = [ "host" ];
            __parentPath = null;
            is = [ traitHost ];
          };
          userNode = {
            name = "tux";
            __path = [
              "host"
              "tux"
            ];
            __parentPath = [ "host" ];
            is = [ traitHome ];
          };
          ctx = mkCtx hostNode [
            hostNode
            userNode
          ];
        in
        matchesOne hostNode ".nixos:has(.homeManager)" ctx;
      expected = true;
    };
    test-css-current-child-selector = {
      expr = matchesOne clusterNode "& > web" (mkCtx clusterNode hierarchyNodes);
      expected = true;
    };
    # programmatic child/descendant constructors
    test-sel-child-match = {
      expr = matchesOne memberNode (sel.child "#cluster" "#web") memberCtx;
      expected = true;
    };
    test-sel-descendant-match = {
      expr = matchesOne memberNode (sel.descendant "#cluster" "#web") memberCtx;
      expected = true;
    };

    # within: node has an ancestor matching the selector
    test-within-match = {
      expr = matchesOne memberNode (sel.within "#cluster") memberCtx;
      expected = true;
    };
    test-within-no-match = {
      expr = matchesOne memberNode (sel.within "#other") memberCtx;
      expected = false;
    };
    # clusterNode has no ancestors → within always false
    test-within-root-no-match = {
      expr = matchesOne clusterNode (sel.within "#cluster") (mkCtx clusterNode hierarchyNodes);
      expected = false;
    };

    # when: arbitrary predicate function receives select (and entity args if declared)
    test-when-match = {
      expr = matchesOne webNode (sel.when ({ select }: select.node.system == "x86_64-linux")) (
        emptyCtx webNode allNodes
      );
      expected = true;
    };
    test-when-no-match = {
      expr = matchesOne webNode (sel.when ({ select }: select.node.system == "aarch64-linux")) (
        emptyCtx webNode allNodes
      );
      expected = false;
    };

    # select.parent: direct parent nodes matching a selector
    test-select-parent-match = {
      expr = memberCtx.select.parent "#cluster" == null;
      expected = false;
    };
    test-select-parent-no-parent = {
      expr = (mkCtx clusterNode hierarchyNodes).select.parent "#cluster" == null;
      expected = true;
    };

    # select.parents: all ancestors matching a selector
    test-select-parents-match = {
      expr = builtins.length (memberCtx.select.parents "#cluster");
      expected = 1;
    };

    # select.within: all descendants of a given node matching a selector
    test-select-within-match = {
      expr = builtins.length ((mkCtx clusterNode hierarchyNodes).select.within clusterNode sel.star);
      expected = 2; # memberNode and otherMemberNode are descendants of clusterNode
    };
    test-select-within-no-descendants = {
      expr = builtins.length ((mkCtx memberNode hierarchyNodes).select.within memberNode sel.star);
      expected = 0; # memberNode has no descendants
    };

    # Multiple attributes chained: [a=1][b=2]
    test-css-multi-attr-chain = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            env = "prod";
            system = "x86_64-linux";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[env=prod][system=x86_64-linux]" ctx;
      expected = true;
    };
    test-css-multi-attr-chain-partial-match = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            env = "prod";
            system = "aarch64-linux";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[env=prod][system=x86_64-linux]" ctx;
      expected = false;
    };

    # Three+ classes chained: .a.b.c
    test-css-three-classes = {
      expr =
        let
          traitTriple = {
            __path = [ "triple" ];
            class = {
              a = _: _: null;
              b = _: _: null;
              c = _: _: null;
            };
          };
          node = makeNode "x" [ traitTriple ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ".a.b.c" ctx;
      expected = true;
    };
    test-css-three-classes-partial = {
      expr =
        let
          traitTriple = {
            __path = [ "triple" ];
            class = {
              a = _: _: null;
              b = _: _: null;
              c = _: _: null;
            };
          };
          node = makeNode "x" [ traitTriple ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ".a.b.x" ctx;
      expected = false;
    };

    # Numeric attribute value: [version=2]
    test-css-attr-numeric = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            version = 2;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[version=2]" ctx;
      expected = true;
    };
    test-css-attr-numeric-string = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            version = "2";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[version=2]" ctx;
      expected = true;
    };

    # Compound with ID and multiple classes: #id.a.b
    test-css-id-multi-class = {
      expr =
        let
          traitAB = {
            __path = [ "ab" ];
            class = {
              a = _: _: null;
              b = _: _: null;
            };
          };
          node = {
            name = "web";
            is = [ traitAB ];
            __path = [ "web" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "#web.a.b" ctx;
      expected = true;
    };

    # Pseudo with compound selector: :has(.a.b)
    test-css-has-compound-classes = {
      expr =
        let
          traitAB = {
            __path = [ "ab" ];
            class = {
              a = _: _: null;
              b = _: _: null;
            };
          };
          parentNode = {
            name = "parent";
            is = [ ];
            __path = [ "parent" ];
            __parentPath = null;
          };
          childNode = {
            name = "child";
            is = [ traitAB ];
            __path = [
              "parent"
              "child"
            ];
            __parentPath = [ "parent" ];
          };
          ctx = mkCtx parentNode [
            parentNode
            childNode
          ];
        in
        matchesOne parentNode "&:has(.a.b)" ctx;
      expected = true;
    };

    # Pseudo with compound selector: :not(.a.b)
    test-css-not-compound-classes = {
      expr =
        let
          node = {
            name = "x";
            is = [ ];
            __path = [ "x" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ":not(.a.b)" ctx;
      expected = true;
    };

    # Empty string selector: "" should parse to star
    test-css-empty-string = {
      expr =
        let
          node = makeNode "x" [ ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "" ctx;
      expected = true;
    };

    # Whitespace-only selector should parse to star
    test-css-whitespace-only = {
      expr =
        let
          node = makeNode "x" [ ] { };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "   " ctx;
      expected = true;
    };

    # Multiple spaces in descendant: cluster  web (double space)
    test-css-multi-space-descendant = {
      expr = matchesOne memberNode "cluster  web" memberCtx;
      expected = true;
    };

    # Case sensitivity in classes: .Prod vs .prod
    test-css-class-case-sensitive = {
      expr =
        let
          traitProd = {
            __path = [ "prod" ];
            class = {
              prod = _: _: null;
            };
          };
          node = makeNode "x" [ traitProd ] { };
          ctx = emptyCtx node [ node ];
        in
        !matchesOne node ".Prod" ctx && matchesOne node ".prod" ctx;
      expected = true;
    };

    # ID with hyphen: #web-1
    test-css-id-with-hyphen = {
      expr =
        let
          node = {
            name = "web-1";
            is = [ ];
            __path = [ "web-1" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "#web-1" ctx;
      expected = true;
    };

    # ID with underscore: #web_1
    test-css-id-with-underscore = {
      expr =
        let
          node = {
            name = "web_1";
            is = [ ];
            __path = [ "web_1" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "#web_1" ctx;
      expected = true;
    };

    # Attribute with hyphenated value
    test-css-attr-hyphenated-value = {
      expr =
        let
          node = {
            name = "x";
            __path = [ "x" ];
            __parentPath = null;
            is = [ ];
            system = "x86-64-linux";
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "[system=x86-64-linux]" ctx;
      expected = true;
    };

    # === TRAIT NAME MATCHING EDGE CASES ===
    # Note: "host.user" in CSS is parsed as name="host" + class="user", NOT as trait path ["host", "user"]
    # To match a trait with path ["host", "user"], must use the programmatic form
    test-nix-dsl-trait-path-with-dots = {
      expr =
        let
          traitHostUser = {
            __path = [
              "host"
              "user"
            ];
          };
          node = {
            name = "x";
            is = [ traitHostUser ];
            __path = [ "x" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node traitHostUser ctx;
      expected = true;
    };
    # CSS: bare name selector matches trait path SUFFIX
    test-name-selector-matches-trait-suffix = {
      expr =
        let
          traitXUser = {
            __path = [
              "x"
              "user"
            ];
          };
          node = {
            name = "y";
            is = [ traitXUser ];
            __path = [ "y" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "user" ctx;
      expected = true;
    };
    # CSS: class selector is NOT the same as trait suffix
    test-class-vs-trait-suffix = {
      expr =
        let
          traitWithClass = {
            __path = [ "x" ];
            class = {
              prod = _: _: null;
            };
          };
          node = {
            name = "y";
            is = [ traitWithClass ];
            __path = [ "y" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ".prod" ctx;
      expected = true;
    };

    # === OR WITH COMPOUND SELECTORS ===
    test-css-or-with-compounds = {
      expr =
        let
          traitLB = {
            __path = [ "lb" ];
            class = {
              load-balancer = _: _: null;
            };
          };
          node1 = {
            name = "web";
            is = [ traitHost ];
            __path = [ "web" ];
            __parentPath = null;
          };
          node2 = {
            name = "lb";
            is = [ traitLB ];
            __path = [ "lb" ];
            __parentPath = null;
          };
          ctx1 = emptyCtx node1 [
            node1
            node2
          ];
          ctx2 = emptyCtx node2 [
            node1
            node2
          ];
        in
        (matchesOne node1 "#web.nixos, #lb.load-balancer" ctx1)
        && (matchesOne node2 "#web.nixos, #lb.load-balancer" ctx2);
      expected = true;
    };
    test-css-or-first-matches = {
      expr =
        let
          node = {
            name = "web";
            is = [ traitHost ];
            __path = [ "web" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "#web.nixos, #other" ctx;
      expected = true;
    };
    test-css-or-second-matches = {
      expr =
        let
          node = {
            name = "other";
            is = [ ];
            __path = [ "other" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "#web.nixos, #other" ctx;
      expected = true;
    };

    # === DEEPLY NESTED HIERARCHY ===
    test-deep-descendant-chain = {
      expr =
        let
          root = {
            name = "root";
            is = [ ];
            __path = [ "root" ];
            __parentPath = null;
          };
          child = {
            name = "child";
            is = [ ];
            __path = [
              "root"
              "child"
            ];
            __parentPath = [ "root" ];
          };
          grandchild = {
            name = "grandchild";
            is = [ ];
            __path = [
              "root"
              "child"
              "grandchild"
            ];
            __parentPath = [
              "root"
              "child"
            ];
          };
          nodes = [
            root
            child
            grandchild
          ];
          ctx = mkCtx grandchild nodes;
        in
        matchesOne grandchild "root child grandchild" ctx;
      expected = true;
    };

    # === GROUPING COMBINATORS ===
    test-grouping-two-traits = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          traitB = {
            __path = [ "b" ];
          };
          node = {
            name = "test";
            is = [
              traitA
              traitB
            ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(a)b" ctx;
      expected = true;
    };

    test-grouping-parens-variant = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          traitB = {
            __path = [ "b" ];
          };
          node = {
            name = "test";
            is = [
              traitA
              traitB
            ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(a)(b)" ctx;
      expected = true;
    };

    test-grouping-missing-first = {
      expr =
        let
          traitB = {
            __path = [ "b" ];
          };
          node = {
            name = "test";
            is = [ traitB ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(a)b" ctx;
      expected = false;
    };

    test-grouping-missing-second = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          node = {
            name = "test";
            is = [ traitA ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(a)b" ctx;
      expected = false;
    };

    test-grouping-three-traits = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          traitB = {
            __path = [ "b" ];
          };
          traitC = {
            __path = [ "c" ];
          };
          node = {
            name = "test";
            is = [
              traitA
              traitB
              traitC
            ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(a)(b)(c)" ctx;
      expected = true;
    };

    test-grouping-with-class = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          traitB = {
            __path = [ "b" ];
          };
          node = {
            name = "test";
            is = [
              traitA
              traitB
            ];
            __path = [ "test" ];
            __parentPath = null;
          };
          # Extract class handler check
          classRec = {
            class = {
              a = true;
            };
          };
          nodeWithClass = node // {
            is = [
              traitA
              traitB
              classRec
            ];
          };
          ctx = emptyCtx nodeWithClass [ nodeWithClass ];
        in
        matchesOne nodeWithClass "(a.x)b" ctx;
      expected = false;
    };

    test-grouping-id-compound = {
      expr =
        let
          traitB = {
            __path = [ "b" ];
          };
          node = {
            name = "web";
            is = [ traitB ];
            __path = [ "web" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node "(#web)b" ctx;
      expected = true;
    };

    # === :is() PSEUDO-SELECTOR ===
    test-is-single-trait = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          node = {
            name = "test";
            is = [ traitA ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ":is(a)" ctx;
      expected = true;
    };

    test-is-single-mismatch = {
      expr =
        let
          traitA = {
            __path = [ "a" ];
          };
          node = {
            name = "test";
            is = [ traitA ];
            __path = [ "test" ];
            __parentPath = null;
          };
          ctx = emptyCtx node [ node ];
        in
        matchesOne node ":is(b)" ctx;
      expected = false;
    };

  };
}
