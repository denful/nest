_nest:
let
  mkPath = prefix: key: prefix ++ [ key ];

  mergeAttrs =
    inheritedAttrs: val:
    inheritedAttrs
    // builtins.listToAttrs (
      builtins.filter (x: !builtins.isAttrs x.value && x.name != "is") (
        map (k: {
          name = k;
          value = val.${k};
        }) (builtins.attrNames val)
      )
    );

  makeNode =
    pathPrefix: parentPath: inheritedAttrs: key: val:
    let
      path = mkPath pathPrefix key;
      node =
        inheritedAttrs
        // val
        // {
          name = key;
          __path = path;
          __parentPath = parentPath;
          is = if builtins.isList val.is then val.is else [ val.is ];
        };
      children = walkDom path path (mergeAttrs inheritedAttrs val) val;
    in
    [ node ] ++ children;

  walkDom =
    pathPrefix: parentPath: inheritedAttrs: attrset:
    builtins.foldl' (
      acc: key:
      let
        val = attrset.${key};
      in
      if !builtins.isAttrs val then
        acc
      else if
        val ? is
        && (
          builtins.isList val.is
          || builtins.isString val.is
          || (builtins.isAttrs val.is && (val.is ? __sel || val.is ? __path))
        )
      then
        acc ++ makeNode pathPrefix parentPath inheritedAttrs key val
      else
        let
          path = mkPath pathPrefix key;
        in
        acc ++ walkDom path parentPath (mergeAttrs inheritedAttrs val) val
    ) [ ] (builtins.attrNames attrset);

  traverseDom = dom: walkDom [ ] null { } dom;
in
{
  inherit traverseDom;
}
