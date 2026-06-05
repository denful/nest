# LABEL-KEYED rules: each key is just a label, the selector lives in `is`. Unlike
# the list form (rules.nix), this attrset form MERGES across import-tree files —
# so these rules combine with rules.nix instead of overwriting it. That makes
# this file a double demo: the label rule form AND cross-file rule merging.
#
# Every selector here is built with the Nix-DSL constructors (`nest.star`,
# `nest.has`, …) instead of a CSS string — handy when a selector is computed.
{ nest, ... }:
let
  tag = feature: { node, ... }: "${node.name}/${feature}";
in
{
  nest.rules = {
    # nest.star — universal.
    dslStar = {
      is = nest.star;
      demo = tag "dsl-star";
    };
    # nest.attrs — match by an attribute set.
    dslAttrs = {
      is = nest.attrs { kind = "db"; };
      demo = tag "dsl-attrs";
    };
    # nest.has — has a matching descendant.
    dslHas = {
      is = nest.has nest.box;
      demo = tag "dsl-has";
    };
    # nest.within — has a matching ancestor.
    dslWithin = {
      is = nest.within nest.box;
      demo = tag "dsl-within";
    };
    # nest.not — negation.
    dslNot = {
      is = nest.not (nest.attrs { env = "prod"; });
      demo = tag "dsl-not";
    };
    # nest.or — any of a list of selectors.
    dslOr = {
      is = nest.or [
        (nest.attrs { kind = "cache"; })
        (nest.attrs { kind = "db"; })
      ];
      demo = tag "dsl-or";
    };
    # nest.class — node whose trait declares this class.
    dslClass = {
      is = nest.class "demo";
      demo = tag "dsl-class";
    };
    # nest.child — direct parent/child.
    dslChild = {
      is = nest.child (nest.attrs { kind = "web"; }) nest.box;
      demo = tag "dsl-child";
    };
    # nest.descendant — ancestor/descendant.
    dslDescendant = {
      is = nest.descendant (nest.attrs { kind = "db"; }) nest.box;
      demo = tag "dsl-descendant";
    };
    # A list of selectors is an AND: box AND env=prod (note inline DSL in `is`).
    listAnd = {
      is = [
        nest.box
        (nest.attrs { env = "prod"; })
      ];
      demo = tag "list-and";
    };
  };
}
