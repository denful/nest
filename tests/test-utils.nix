nest: {

  nestTest =
    module:
    let
      nonNest = builtins.filter (k: k != "nest") (builtins.attrNames (builtins.functionArgs module));
      # Fold a list of module attrsets into one — for use in test class fns.
      # Real usage passes the list to nixosSystem; tests fold it for assertion access.
      testMerge = modules: builtins.foldl' nest.deepMerge { } modules;
      # Single-pass: nestDot lazily points at result.nest.trait.
      # Safe because trait attrset structure never forces fn bodies.
      nestDot = nest.injectNames (result.nest.trait or { }) // nest.mkSelectors // { inherit testMerge; };
      evalResult = nest.evalNest (result.nest or { });
      result = module (
        {
          nest = nestDot;
        }
        // builtins.listToAttrs (
          map (k: {
            name = k;
            value = evalResult.outputs.${k};
          }) nonNest
        )
      );
    in
    { inherit (result) expr; } // (if result ? expected then { inherit (result) expected; } else { });

  makeNode =
    name: is: extra:
    {
      inherit name is;
      __path = [ name ];
      __parentPath = null;
    }
    // extra;

  emptyCtx = node: allNodes: nest.mkCtx node allNodes;

}
