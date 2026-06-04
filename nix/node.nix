nest:
let
  # Fold a class fn's result (attrset of lists) into an accumulator,
  # concatenating module lists per key.
  mergeClassResult =
    acc: result:
    if !builtins.isAttrs result then
      acc
    else
      builtins.foldl' (
        a: k:
        let
          v = result.${k};
        in
        a // { ${k} = (a.${k} or [ ]) ++ (if builtins.isList v then v else [ v ]); }
      ) acc (builtins.attrNames result);

  # Shared setup for a node: its class functions, its merged modules
  # (own cfg + contributions from child nodes), and a select context.
  # Both `processNode` and `childContrib` need exactly this.
  classScope =
    nd: allAnnotated:
    let
      entityT = nest.firstMatch (t: t ? class) nd.is;
    in
    {
      classFns = if entityT != null then entityT.class else { };
      mods = nest.mergeModuleLists nd.__mergedCfg (nest.collectChildFrags nd allAnnotated);
      inherit ((nest.mkCtx nd allAnnotated)) select;
    };

  # A child contributes ALL of its class outputs to its parent (merged).
  # No `is`-class trait → empty classFns → empty fold → { }.
  childContrib =
    allAnnotated: child:
    let
      s = classScope child allAnnotated;
    in
    builtins.foldl' (
      acc: className: mergeClassResult acc (s.classFns.${className} s.select (s.mods.${className} or [ ]))
    ) { } (builtins.attrNames s.classFns);

  # A node produces its FIRST non-null class output, or null if it has none.
  processNode =
    node: allAnnotated:
    let
      s = classScope node allAnnotated;
    in
    builtins.foldl' (
      acc: className:
      if acc != null then
        acc
      else
        let
          value = s.classFns.${className} s.select (s.mods.${className} or [ ]);
        in
        if value != null then
          {
            inherit (node) name;
            inherit className value;
          }
        else
          null
    ) null (builtins.attrNames s.classFns);

  collectChildFrags =
    parentNode: allAnnotated:
    builtins.foldl' nest.mergeModuleLists { } (
      map (childContrib allAnnotated) (
        builtins.filter (n: n.__parentPath == parentNode.__path) allAnnotated
      )
    );
in
{
  inherit processNode collectChildFrags;
}
