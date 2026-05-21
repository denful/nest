nest:
let
  isTraitSelector = expr: builtins.isString expr || (builtins.isAttrs expr && expr ? __sel);

  hasPath = item: list: builtins.any (x: x ? __path && x.__path == item.__path) list;

  traverseNamedTraits =
    tree:
    let
      go =
        parentPath: attrs:
        builtins.concatLists (
          map (
            k:
            let
              v = attrs.${k};
            in
            if builtins.isAttrs v && v ? __path then
              [
                {
                  key = k;
                  value = v;
                  inherit parentPath;
                }
              ]
              ++ go v.__path (builtins.removeAttrs v nest.traitSpecialKeys)
            else
              [ ]
          ) (builtins.attrNames attrs)
        );
    in
    go null tree;

  resolveTraitRefs =
    processedTraits: expr:
    if expr == null then
      [ ]
    else if builtins.isFunction expr then
      resolveTraitRefs processedTraits (expr processedTraits)
    else if builtins.isList expr then
      builtins.concatMap (x: resolveTraitRefs processedTraits x) expr
    else if builtins.isAttrs expr && expr ? __path then
      [ expr ]
    else if isTraitSelector expr then
      nest.selectTraits processedTraits expr
    else
      [ ];

  nodeHasSelectedTrait =
    processedTraits: nodeIs: sel:
    let
      selected = nest.selectTraits processedTraits sel;
    in
    builtins.any (have: nest.hasPath have selected) nodeIs;

  expandTraitsRec =
    processedTraits: allNodes: seen: queue:
    if queue == [ ] then
      seen
    else
      let
        t = builtins.head queue;
        rest = builtins.tail queue;
      in
      if hasPath t seen then
        expandTraitsRec processedTraits allNodes seen rest
      else
        let
          rawNeeds = t.needs or null;
          needed = resolveTraitRefs processedTraits rawNeeds;
        in
        expandTraitsRec processedTraits allNodes (seen ++ [ t ]) (rest ++ needed);

  expandTraits =
    processedTraits: traitList: allNodes:
    expandTraitsRec processedTraits allNodes [ ] traitList;
in
{
  inherit
    hasPath
    traverseNamedTraits
    resolveTraitRefs
    nodeHasSelectedTrait
    expandTraits
    ;
}
