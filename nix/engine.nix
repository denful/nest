nest:
let
  expandNode =
    traits: rawNodes: n:
    let
      expandedIs = nest.expandTraits traits n.is rawNodes;
      fullIs = nest.expandNeededBy traits expandedIs (builtins.removeAttrs n [ "is" ]) rawNodes;
    in
    n // { is = fullIs; };

  annotateNode =
    rules: synthesizedNodes: node:
    let
      ctx = nest.mkCtx node synthesizedNodes;
      matchingRules = builtins.filter (r: nest.matchesOne node r.is ctx) rules;
    in
    node // { __mergedCfg = nest.mergeRuleConfigs node matchingRules ctx; };

  collectRawOutputs =
    rootNodes: allAnnotated:
    builtins.filter (x: x != null && x.value != null) (
      map (n: nest.processNode n allAnnotated) rootNodes
    );

  makeByClass =
    rawOutputs:
    builtins.foldl' (
      acc: x:
      acc
      // {
        ${x.className} = (acc.${x.className} or { }) // {
          ${x.name} = x.value;
        };
      }
    ) { } rawOutputs;

  evalNest =
    nestCfg:
    let
      traits = nest.injectNames (nestCfg.trait or { });
      rawRules = nestCfg.rules or [ ];
      rules =
        if builtins.isList rawRules then
          rawRules
        else
          map (k: { is = k; } // rawRules.${k}) (builtins.attrNames rawRules);
      rawNodes = nest.traverseDom (
        builtins.removeAttrs nestCfg [
          "trait"
          "rules"
        ]
      );
      expandedNodes = map (n: expandNode traits rawNodes n) rawNodes;
      synthesizedNodes = nest.synthesizeNodes traits expandedNodes;
      annotated = map (n: annotateNode rules synthesizedNodes n) synthesizedNodes;
      finalAnnotated = nest.applyRuleSynth traits rules annotated synthesizedNodes;
      rootNodes = builtins.filter (n: n.__parentPath == null) finalAnnotated;
      rawOutputs = collectRawOutputs rootNodes finalAnnotated;
      outputs = builtins.listToAttrs (
        map (x: {
          inherit (x) name;
          inherit (x) value;
        }) rawOutputs
      );
      byClass = makeByClass rawOutputs;
    in
    {
      inherit outputs byClass;
    };
in
{
  inherit evalNest;
}
