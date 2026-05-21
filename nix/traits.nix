nest:
let
  traitSpecialKeys = [
    "class"
    "needs"
    "neededBy"
    "synth"
    "__path"
  ];

  injectNamesRec =
    prefix: tree:
    builtins.mapAttrs (
      k: v:
      if builtins.elem k traitSpecialKeys then
        v
      else if !builtins.isAttrs v then
        v
      else
        (injectNamesRec (prefix ++ [ k ]) v) // { __path = prefix ++ [ k ]; }
    ) tree;

  injectNames = traits: injectNamesRec [ ] traits;

  traitNode =
    n:
    let
      trait = n.value;
    in
    (builtins.removeAttrs trait traitSpecialKeys)
    // {
      name = n.key;
      inherit (trait) __path;
      __parentPath = n.parentPath;
      is = [ trait ];
    };

  selectTraits =
    processedTraits: sel:
    let
      nodes = map traitNode (nest.traverseNamedTraits processedTraits);
    in
    map (n: builtins.head n.is) (builtins.filter (n: nest.matchesOne n sel (nest.mkCtx n nodes)) nodes);
in
{
  inherit traitSpecialKeys injectNames selectTraits;
}
