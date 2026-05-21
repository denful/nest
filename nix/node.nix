nest:
let
  mergeClassResult =
    acc: result:
    if builtins.isAttrs result then
      builtins.foldl' (
        a: k:
        let
          v = result.${k};
        in
        a // { ${k} = (a.${k} or [ ]) ++ (if builtins.isList v then v else [ v ]); }
      ) acc (builtins.attrNames result)
    else
      acc;

  childContrib =
    allAnnotated: child:
    let
      entityT = nest.firstMatch (t: t ? class) child.is;
      classFns = if entityT != null then entityT.class else { };
      childMods = nest.mergeModuleLists child.__mergedCfg (nest.collectChildFrags child allAnnotated);
      inherit ((nest.mkCtx child allAnnotated)) select;
    in
    if entityT == null then
      { }
    else
      builtins.foldl' (
        acc: className:
        let
          result = classFns.${className} select (childMods.${className} or [ ]);
        in
        mergeClassResult acc result
      ) { } (builtins.attrNames classFns);

  processNode =
    node: allAnnotated:
    let
      entityT = nest.firstMatch (t: t ? class) node.is;
      classFns = if entityT != null then entityT.class else { };
      allMods = nest.mergeModuleLists node.__mergedCfg (nest.collectChildFrags node allAnnotated);
      inherit ((nest.mkCtx node allAnnotated)) select;
    in
    if entityT == null then
      null
    else
      builtins.foldl' (
        acc: className:
        if acc != null then
          acc
        else
          let
            value = classFns.${className} select (allMods.${className} or [ ]);
          in
          if value != null then
            {
              inherit (node) name;
              inherit className value;
            }
          else
            null
      ) null (builtins.attrNames classFns);

  collectChildFrags =
    parentNode: allAnnotated:
    let
      children = builtins.filter (n: n.__parentPath == parentNode.__path) allAnnotated;
    in
    builtins.foldl' nest.mergeModuleLists { } (map (child: childContrib allAnnotated child) children);
in
{
  inherit processNode collectChildFrags;
}
