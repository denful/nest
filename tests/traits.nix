nest:
let
  inherit (nest) injectNames expandTraits makeNode;

  rawTraits = {
    server = { };
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
    nginx = { };
    monitoring = {
      node-exporter = { };
    };
    lb = {
      needs = _: [ processedTraits.server ];
    };
    ssh = { };
    firewall = { };
  };

  processedTraits = injectNames rawTraits;
in
{
  traits = {
    test-inject-traitname = {
      expr = processedTraits.server.__path;
      expected = [ "server" ];
    };
    test-inject-nested-traitname = {
      expr = processedTraits.monitoring.node-exporter.__path;
      expected = [
        "monitoring"
        "node-exporter"
      ];
    };
    test-inject-parent-traitname = {
      expr = processedTraits.monitoring.__path;
      expected = [ "monitoring" ];
    };
    test-inject-preserves-class = {
      expr = processedTraits.host ? class;
      expected = true;
    };
    test-expand-needs = {
      # lb needs server; server in expanded set
      expr = builtins.any (t: t.__path == [ "server" ]) (
        expandTraits processedTraits [ processedTraits.lb ] [ ]
      );
      expected = true;
    };
    test-expand-direct-trait = {
      # original trait kept
      expr = builtins.any (t: t.__path == [ "lb" ]) (
        expandTraits processedTraits [ processedTraits.lb ] [ ]
      );
      expected = true;
    };
    test-expand-no-dupes = {
      # expanding [server server] → still just one server
      expr = builtins.length (
        builtins.filter (t: t.__path == [ "server" ]) (
          expandTraits processedTraits [ processedTraits.server processedTraits.server ] [ ]
        )
      );
      expected = 1;
    };

    # multi-level needs chain: lb → server (via needs fn) — server included
    test-expand-multi-level = {
      expr = builtins.any (t: t.__path == [ "server" ]) (
        expandTraits processedTraits [ processedTraits.lb ] [ ]
      );
      expected = true;
    };

    # expandNeededBy: monitoring has neededBy = server → injected on server nodes
    test-neededby-injected = {
      expr =
        let
          traitsWithNeededBy = injectNames (
            rawTraits
            // {
              monitoring = {
                neededBy = processedTraits.server;
              };
            }
          );
          serverIs = expandTraits traitsWithNeededBy [ traitsWithNeededBy.server ] [ ];
          serverNode = makeNode "srv" serverIs { };
          fullIs = nest.expandNeededBy traitsWithNeededBy serverIs { } [ serverNode ];
        in
        builtins.any (t: t.__path == [ "monitoring" ]) fullIs;
      expected = true;
    };

    # expandNeededBy: monitoring NOT injected on non-server nodes
    test-neededby-not-injected = {
      expr =
        let
          traitsWithNeededBy = injectNames (
            rawTraits
            // {
              monitoring = {
                neededBy = processedTraits.server;
              };
            }
          );
          adminIs = expandTraits traitsWithNeededBy [ traitsWithNeededBy.admin ] [ ];
          adminNode = makeNode "adm" adminIs { };
          fullIs = nest.expandNeededBy traitsWithNeededBy adminIs { } [ adminNode ];
        in
        builtins.any (t: t.__path == [ "monitoring" ]) fullIs;
      expected = false;
    };

    # needs: selector string can select nested traits from trait tree
    test-needs-selector-nested = {
      expr =
        let
          traitsWithSelectorNeeds = injectNames (
            rawTraits
            // {
              collector = {
                needs = [ "monitoring > node-exporter" ];
              };
            }
          );
          expanded = expandTraits traitsWithSelectorNeeds [ traitsWithSelectorNeeds.collector ] [ ];
        in
        builtins.any (
          t:
          t.__path == [
            "monitoring"
            "node-exporter"
          ]
        ) expanded;
      expected = true;
    };

    # neededBy: selector string can target nested traits on node.is
    test-neededby-selector-nested = {
      expr =
        let
          traitsWithSelectorNeededBy = injectNames (
            rawTraits
            // {
              telemetry = {
                neededBy = "monitoring > node-exporter";
              };
            }
          );
          nodeIs =
            expandTraits traitsWithSelectorNeededBy
              [ traitsWithSelectorNeededBy.monitoring.node-exporter ]
              [ ];
          node = makeNode "exp" nodeIs { };
          fullIs = nest.expandNeededBy traitsWithSelectorNeededBy nodeIs { } [ node ];
        in
        builtins.any (t: t.__path == [ "telemetry" ]) fullIs;
      expected = true;
    };

    # flattenTraitTree: returns all traits including nested
    test-flatten-trait-tree = {
      expr =
        let
          names = map (t: t.__path) (nest.flattenTraitTree processedTraits);
        in
        builtins.elem [ "monitoring" "node-exporter" ] names;
      expected = true;
    };
  };
}
