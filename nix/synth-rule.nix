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
    rules: withSynth: origPaths: node:
    if builtins.elem node.__path origPaths then node else nest.annotateNode rules withSynth node;

  applyRuleSynth =
    processedTraits: rules: annotated: synthesizedNodes:
    let
      withSynth = nest.flatMapSynth (synthOne processedTraits synthesizedNodes) annotated;
      origPaths = map (n: n.__path) annotated;
    in
    map (annotateSynthNode rules withSynth origPaths) withSynth;
in
{
  inherit applyRuleSynth;
}
