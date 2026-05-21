nest:
let
  expandChild =
    processedTraits: refNodes: parentNode: child:
    let
      expandedIs = nest.expandTraits processedTraits child.is refNodes;
      fullIs = nest.expandNeededBy processedTraits expandedIs (builtins.removeAttrs child [
        "is"
      ]) refNodes;
    in
    child
    // {
      __path = parentNode.__path ++ [ child.name ];
      __parentPath = parentNode.__path;
      is = fullIs;
    };

  applySynth =
    processedTraits: refNodes: synthResult: parentNode:
    let
      nodeData = synthResult.node or { };
      plainAttrs = builtins.removeAttrs nodeData [ "children" ];
      rawChildren = nodeData.children or [ ];
    in
    {
      node = parentNode // plainAttrs;
      children = map (child: expandChild processedTraits refNodes parentNode child) rawChildren;
    };

  synthOne =
    processedTraits: expandedNodes: node:
    let
      entityT = nest.firstMatch (t: t ? class) node.is;
      synthFn = if entityT != null && entityT ? synth then entityT.synth else null;
    in
    if synthFn == null then
      {
        inherit node;
        children = [ ];
      }
    else
      let
        ctx = nest.mkCtx node expandedNodes;
        synthResult = nest.callWithArgs synthFn node ctx;
      in
      nest.applySynth processedTraits expandedNodes synthResult node;

  synthesizeNodes =
    processedTraits: expandedNodes:
    builtins.concatMap (
      node:
      let
        r = synthOne processedTraits expandedNodes node;
      in
      [ r.node ] ++ r.children
    ) expandedNodes;
in
{
  inherit applySynth synthesizeNodes;
}
