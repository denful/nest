# The `box` trait gives every node a `demo` class. nest collects outputs from
# ROOT nodes only — a child's class result merges UP into its parent — so `demo`
# re-emits everything under the `demo` key (an attrset, which is what lets nest
# merge it upward). The class ALSO computes graph facts from its `select`
# context, proving the traversal helpers: select.parentNode, select.children,
# select.siblings, select.within (descendants), select.parents (ancestors).
{ nest, ... }:
{
  nest.trait.box.class.demo =
    select: tags:
    let
      self = select.node.name;
      inherit (select) parentNode;
      parentName = if parentNode == null then "root" else parentNode.name;
      childTags = map (n: "${self}/child=${n.name}") (select.children nest.box);
      siblingTags = map (n: "${self}/sibling=${n.name}") (select.siblings nest.box);
      descendantTags = map (n: "${self}/desc=${n.name}") (select.within select.node nest.box);
      ancestorTags = map (n: "${self}/anc=${n.name}") (select.parents nest.box);
    in
    {
      demo =
        tags
        ++ [ "${self}/parent=${parentName}" ]
        ++ childTags
        ++ siblingTags
        ++ descendantTags
        ++ ancestorTags;
    };
}
