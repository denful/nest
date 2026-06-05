nest:
let
  last = list: if list == [ ] then null else builtins.elemAt list (builtins.length list - 1);

  firstMatch =
    pred: list:
    let
      ms = builtins.filter pred list;
    in
    if ms == [ ] then null else builtins.head ms;

  childOf = allNodes: p: builtins.filter (n: n.__parentPath == p.__path) allNodes;

  findAncestors =
    allNodes: path:
    if path == null then
      [ ]
    else
      let
        p = firstMatch (n: n.__path == path) allNodes;
      in
      if p == null then [ ] else [ p ] ++ findAncestors allNodes p.__parentPath;

  findDescendants =
    allNodes: nd:
    let
      cs = childOf allNodes nd;
    in
    cs ++ builtins.concatLists (map (c: findDescendants allNodes c) cs);

  mkFilter = list: sel: builtins.filter (n: nest.matchesOne n sel (nest.mkCtx n list)) list;

  mkParentSel =
    parentNode:
    if parentNode == null then _: null else sel: firstMatch (_: true) (mkFilter [ parentNode ] sel);

  mkCtx =
    node: allNodes:
    let
      children = childOf allNodes node;
      ancestors = findAncestors allNodes node.__parentPath;
      descendants = findDescendants allNodes node;
      descendantsFn = findDescendants allNodes;
      siblings = builtins.filter (
        n: n.__parentPath == node.__parentPath && n.__path != node.__path
      ) allNodes;
      parentNode = if ancestors == [ ] then null else builtins.head ancestors;
      parentSel = mkParentSel parentNode;
    in
    {
      inherit
        children
        ancestors
        descendants
        descendantsFn
        allNodes
        parentNode
        ;
      select = {
        __functor = _: mkFilter allNodes;
        inherit node;
        inherit parentNode;
        within = nd: mkFilter (descendantsFn nd);
        siblings = mkFilter siblings;
        children = mkFilter children;
        parent = parentSel;
        parents = mkFilter ancestors;
      };
    };
in
{
  inherit firstMatch mkCtx last;
}
