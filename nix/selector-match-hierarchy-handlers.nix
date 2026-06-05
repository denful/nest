nest:
let
  isCurrentSel = s: builtins.isAttrs s && s.__sel == "current";

  findPreviousSibling =
    node: list: prev:
    if list == [ ] then
      null
    else
      let
        h = builtins.head list;
        t = builtins.tail list;
      in
      if h.__path == node.__path then prev else findPreviousSibling node t h;

  findNextSibling =
    node: list:
    if list == [ ] then
      null
    else
      let
        h = builtins.head list;
        t = builtins.tail list;
      in
      if h.__path == node.__path then
        if t == [ ] then null else builtins.head t
      else
        findNextSibling node t;

  handleChild =
    node: sel: ctx:
    if isCurrentSel sel.parentSel then
      builtins.any (n: nest.matchesOne n sel.childSel (nest.mkCtx n ctx.allNodes)) ctx.children
    else
      ctx.parentNode != null
      && nest.matchesOne node sel.childSel ctx
      && nest.matchesOne ctx.parentNode sel.parentSel (nest.mkCtx ctx.parentNode ctx.allNodes);

  handleDescendant =
    node: sel: ctx:
    if isCurrentSel sel.ancestorSel then
      builtins.any (n: nest.matchesOne n sel.descendantSel (nest.mkCtx n ctx.allNodes)) ctx.descendants
    else
      nest.matchesOne node sel.descendantSel ctx
      && builtins.any (a: nest.matchesOne a sel.ancestorSel (nest.mkCtx a ctx.allNodes)) ctx.ancestors;

  handleAdjacent =
    node: sel: ctx:
    let
      siblings = builtins.filter (n: n.__parentPath == node.__parentPath) ctx.allNodes;
      prev = findPreviousSibling node siblings null;
      next = findNextSibling node siblings;
      prevCur = isCurrentSel sel.previousSel;
      nextCur = isCurrentSel sel.nextSel;
    in
    if prevCur then
      next != null && nest.matchesOne next sel.nextSel (nest.mkCtx next ctx.allNodes)
    else if nextCur then
      prev != null && nest.matchesOne prev sel.previousSel (nest.mkCtx prev ctx.allNodes)
    else
      prev != null
      && nest.matchesOne prev sel.previousSel (nest.mkCtx prev ctx.allNodes)
      && nest.matchesOne node sel.nextSel ctx;
in
{
  inherit
    handleChild
    handleDescendant
    handleAdjacent
    ;
}
