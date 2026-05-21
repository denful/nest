nest:
let
  simple = import ./selector-match-simple-handlers.nix nest;
  hierarchy = import ./selector-match-hierarchy-handlers.nix nest;

  matchesSel =
    node: sel: ctx:
    let
      matchesAttrValue =
        key: val:
        if !(node ? ${key}) then
          false
        else if val == "true" then
          (builtins.isAttrs node.${key} && false)
          || (builtins.isList node.${key} && false)
          || builtins.elem node.${key} [
            true
            "true"
          ]
        else if val == "false" then
          (builtins.isAttrs node.${key} && false)
          || (builtins.isList node.${key} && false)
          || builtins.elem node.${key} [
            false
            "false"
          ]
        else
          builtins.toString node.${key} == val;
      handlers = {
        star = true;
        id = node.name == sel.name;
        name = node.name == sel.name || builtins.any (t: simple.matchesTraitName sel.name t) node.is;
        attr = matchesAttrValue sel.key sel.val;
        attrExists = node ? ${sel.key};
        attrs = builtins.all (k: (node ? ${k}) && node.${k} == sel.attrs.${k}) (
          builtins.attrNames sel.attrs
        );
        or = builtins.any (x: nest.matchesOne node x ctx) sel.selectors;
        not = simple.handleNot node sel ctx;
        is = builtins.any (x: nest.matchesOne node x ctx) (
          if builtins.isList sel.selector then sel.selector else [ sel.selector ]
        );
        current = true;
        has = simple.handleHas node sel ctx;
        within = simple.handleWithin node sel ctx;
        when = nest.callWithArgs sel.fn node ctx;
        class = simple.handleClass node sel ctx;
        child = hierarchy.handleChild node sel ctx;
        descendant = hierarchy.handleDescendant node sel ctx;
        adjacent = hierarchy.handleAdjacent node sel ctx;
      };
    in
    handlers.${sel.__sel} or false;

  callWithArgs =
    fn: node: ctx:
    let
      fnArgs = builtins.functionArgs fn;
      parentArgs = builtins.listToAttrs (
        builtins.filter (x: x.value != null) (
          map (name: {
            inherit name;
            value = ctx.select.parent name;
          }) (builtins.attrNames fnArgs)
        )
      );
      entityArgs = builtins.listToAttrs (
        map (t: {
          name = nest.last t.__path;
          value = node;
        }) (node.is or [ ])
      );
      args =
        parentArgs
        // entityArgs
        // ctx.select
        // {
          inherit (ctx) select;
          inherit node;
          __functor = _: ctx.select;
        };
      satisfied = builtins.intersectAttrs fnArgs args;
      remaining = builtins.removeAttrs fnArgs (builtins.attrNames satisfied);
    in
    if fnArgs == { } then
      fn args
    else if remaining == { } then
      fn satisfied
    else
      {
        __functionArgs = remaining;
        __functor = _self: a: fn (satisfied // a);
      };
in
{
  inherit matchesSel callWithArgs;
}
