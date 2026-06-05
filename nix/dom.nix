# traverseDom flattens the nested DOM attrset into a flat node list.
# A key is a NODE when its value carries `is` (a selector/trait list);
# a value without `is` is a NAMESPACE wrapper: it organizes the tree and
# its scalar attrs inherit downward, but it is not itself a node.
# __path = full key path; __parentPath = nearest ancestor *node* path
# (namespace wrappers are skipped), or null at the root.
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

  isNode =
    val:
    val ? is
    && (
      builtins.isList val.is
      || builtins.isString val.is
      || (builtins.isAttrs val.is && (val.is ? __sel || val.is ? __path))
    );

  walkDom =
    pathPrefix: parentPath: inheritedAttrs: attrset:
    builtins.foldl' (
      acc: key:
      let
        val = attrset.${key};
      in
      # leaf attr → skip; node (`is`) → emit; namespace → recurse, no node
      if !builtins.isAttrs val then
        acc
      else if isNode val then
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
