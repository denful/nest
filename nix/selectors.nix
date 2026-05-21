nest:
let
  mkSelectors = {
    star = {
      __sel = "star";
    };
    attrs = a: {
      __sel = "attrs";
      attrs = a;
    };
    or = ss: {
      __sel = "or";
      selectors = ss;
    };
    not = s: {
      __sel = "not";
      selector = s;
    };
    has = s: {
      __sel = "has";
      selector = s;
    };
    within = s: {
      __sel = "within";
      selector = s;
    };
    when = f: {
      __sel = "when";
      fn = f;
    };
    class = n: {
      __sel = "class";
      name = n;
    };
    child = p: c: {
      __sel = "child";
      parentSel = p;
      childSel = c;
    };
    descendant = a: d: {
      __sel = "descendant";
      ancestorSel = a;
      descendantSel = d;
    };
  };

  matchesOne =
    node: sel: ctx:
    if builtins.isList sel then
      builtins.all (s: nest.matchesOne node s ctx) sel
    else if builtins.isString sel then
      nest.matchesOne node (nest.parseCssSel sel) ctx
    else if sel ? __sel then
      nest.matchesSel node sel ctx
    else if sel ? __path then
      builtins.any (t: t ? __path && t.__path == sel.__path) node.is
    else
      false;
in
{
  inherit mkSelectors matchesOne;
}
