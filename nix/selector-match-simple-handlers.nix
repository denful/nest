nest:
let
  matchesTraitName =
    name: t:
    t ? __path
    && (
      builtins.concatStringsSep "." t.__path == name
      ||
        builtins.match (builtins.concatStringsSep "" [
          ".*\\."
          name
          "$"
        ]) (builtins.concatStringsSep "." t.__path) != null
    );

  handleNot =
    node: sel: ctx:
    !(builtins.any (s: nest.matchesOne node s ctx) (
      if builtins.isList sel.selector then sel.selector else [ sel.selector ]
    ));

  handleClass =
    node: sel: _:
    (nest.firstMatch (x: x ? class) node.is) != null
    && (nest.firstMatch (x: x ? class) node.is).class ? ${sel.name};

  handleHas =
    _node: sel: ctx:
    builtins.any (n: nest.matchesOne n sel.selector (nest.mkCtx n ctx.allNodes)) ctx.descendants;

  handleWithin =
    _node: sel: ctx:
    builtins.any (n: nest.matchesOne n sel.selector (nest.mkCtx n ctx.allNodes)) ctx.ancestors;
in
{
  inherit
    handleNot
    handleClass
    handleHas
    handleWithin
    matchesTraitName
    ;
}
