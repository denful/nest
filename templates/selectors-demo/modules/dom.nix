# The DOM under test. `fleet` has no `is`, so it is a NAMESPACE: it groups the
# nodes and its scalar attrs (region) inherit downward, but it is not itself a
# node. alpha/beta/gamma are sibling nodes (sorted by key: alpha < beta < gamma);
# sidecar and leaf are children. This shape exercises every combinator
# (siblings for `+`, parent/child for `>`, ancestor/descendant for ` ` and
# `:within`) and the `select.*` traversal helpers.
{ nest, ... }:
{
  nest.fleet = {
    region = "eu"; # inherited by every node below

    alpha = {
      is = [ nest.box ];
      env = "prod";
      kind = "web";
      sidecar = {
        is = [ nest.box ];
        kind = "cache";
        pinned = true; # only sidecar has this attr
      };
    };

    beta = {
      is = [ nest.box ];
      env = "staging";
      kind = "web";
      active = true; # boolean attr, for [active=true]
    };

    gamma = {
      is = [ nest.box ];
      env = "prod";
      kind = "db";
      leaf = {
        is = [ nest.box ];
        kind = "cache";
      };
    };
  };
}
