nest:
let
  synthOne =
    processedTraits: synthesizedNodes: node:
    let
      extra = node.__mergedCfg.synth or null;
    in
    if extra == null then
      {
        inherit node;
        children = [ ];
      }
    else
      nest.applySynth processedTraits synthesizedNodes extra node;

  annotateSynthNode =
    _processedTraits: rules: withSynth: origPaths: node:
    if builtins.elem node.__path origPaths then
      node
    else
      let
        ctx = nest.mkCtx node withSynth;
        matchingRules = builtins.filter (r: nest.matchesOne node r.is ctx) rules;
      in
      node // { __mergedCfg = nest.mergeRuleConfigs node matchingRules ctx; };

  applyRuleSynth =
    processedTraits: rules: annotated: synthesizedNodes:
    let
      withSynth = builtins.concatMap (
        node:
        let
          r = synthOne processedTraits synthesizedNodes node;
        in
        [ r.node ] ++ r.children
      ) annotated;
      origPaths = map (n: n.__path) annotated;
      annotatedWithSynth = map (
        node: annotateSynthNode processedTraits rules withSynth origPaths node
      ) withSynth;
    in
    annotatedWithSynth;
in
{
  inherit applyRuleSynth;
}
