nest:
let
  flattenTraitTree = tree: map (n: n.value) (nest.traverseNamedTraits tree);

  expandNeededByRec =
    processedTraits: allNodes: nodeAttrs: nodeIsAcc:
    let
      virtualNode = nodeAttrs // {
        is = nodeIsAcc;
      };
      ctx = nest.mkCtx virtualNode allNodes;
      allTraits = flattenTraitTree processedTraits;
      extras = builtins.filter (
        t:
        (t ? neededBy)
        && !(nest.hasPath t nodeIsAcc)
        && (
          nest.nodeHasSelectedTrait processedTraits nodeIsAcc t.neededBy
          || nest.matchesOne virtualNode t.neededBy ctx
        )
      ) allTraits;
    in
    if extras == [ ] then
      nodeIsAcc
    else
      expandNeededByRec processedTraits allNodes nodeAttrs (nodeIsAcc ++ extras);

  expandNeededBy =
    processedTraits: nodeIs: nodeAttrs: allNodes:
    expandNeededByRec processedTraits allNodes nodeAttrs nodeIs;
in
{
  inherit flattenTraitTree expandNeededBy;
}
