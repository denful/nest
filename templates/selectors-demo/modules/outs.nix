# Exposes the self-tests. nest collects outputs per ROOT node; each root's
# `demo` value lists the "<node>/<feature>" tags from its whole subtree (child
# tags bubble up). We flatten all roots into one tag set and assert per-feature
# which nodes matched — order-independent. Run with `just check selectors-demo`.
{
  config,
  lib,
  inputs,
  ...
}:
let
  roots = config.flake.nest.evalResult.byClass.demo or { };
  allTags = builtins.sort (a: b: a < b) (
    builtins.concatLists (map (r: r.demo or [ ]) (builtins.attrValues roots))
  );
  # all "<node>" that matched a given feature, sorted.
  matched = f: builtins.filter (lib.hasSuffix "/${f}") allTags;
  has = t: builtins.elem t allTags;
in
{
  imports = [ inputs.nest.flakeModule ];

  options.flake.tests = lib.mkOption { };

  config.flake.tests = {
    # Only alpha/beta/gamma are roots; sidecar & leaf bubble into their parents.
    "test-roots" = {
      expr = builtins.attrNames roots;
      expected = [
        "alpha"
        "beta"
        "gamma"
      ];
    };

    # ── simple forms ──
    "test-star" = {
      expr = matched "all";
      expected = [
        "alpha/all"
        "beta/all"
        "gamma/all"
        "leaf/all"
        "sidecar/all"
      ];
    };
    "test-id" = {
      expr = matched "id";
      expected = [ "gamma/id" ];
    };
    "test-attr-eq" = {
      expr = matched "attr-eq";
      expected = [ "gamma/attr-eq" ];
    };
    "test-bool" = {
      expr = matched "bool";
      expected = [ "beta/bool" ];
    };
    "test-attr-exists" = {
      expr = matched "attr-exists";
      expected = [ "sidecar/attr-exists" ];
    };

    # ── combinators ──
    "test-descendant" = {
      expr = matched "descendant";
      expected = [ "leaf/descendant" ];
    };
    "test-child" = {
      expr = matched "child";
      expected = [ "sidecar/child" ];
    };
    "test-adjacent" = {
      expr = matched "adjacent";
      expected = [ "beta/adjacent" ];
    };
    "test-group" = {
      expr = matched "group";
      expected = [
        "alpha/group"
        "beta/group"
      ];
    };
    "test-current-child" = {
      expr = matched "current-child";
      expected = [
        "alpha/current-child"
        "gamma/current-child"
      ];
    };

    # ── pseudo-classes ──
    "test-has" = {
      expr = matched "has";
      expected = [
        "alpha/has"
        "gamma/has"
      ];
    };
    "test-not" = {
      expr = matched "not";
      expected = [ "beta/not" ];
    };
    "test-is-pseudo" = {
      expr = matched "is-pseudo";
      expected = [
        "beta/is-pseudo"
        "gamma/is-pseudo"
      ];
    };
    "test-within" = {
      expr = matched "within";
      expected = [ "leaf/within" ];
    };

    # ── predicate selector ──
    "test-when" = {
      expr = matched "when";
      expected = [ "gamma/when" ];
    };

    # ── Nix-DSL selectors (label-keyed rules in rules-dsl.nix, merged cross-file) ──
    "test-dsl-star" = {
      expr = matched "dsl-star";
      expected = [
        "alpha/dsl-star"
        "beta/dsl-star"
        "gamma/dsl-star"
        "leaf/dsl-star"
        "sidecar/dsl-star"
      ];
    };
    "test-dsl-attrs" = {
      expr = matched "dsl-attrs";
      expected = [ "gamma/dsl-attrs" ];
    };
    "test-dsl-has" = {
      expr = matched "dsl-has";
      expected = [
        "alpha/dsl-has"
        "gamma/dsl-has"
      ];
    };
    "test-dsl-within" = {
      expr = matched "dsl-within";
      expected = [
        "leaf/dsl-within"
        "sidecar/dsl-within"
      ];
    };
    "test-dsl-not" = {
      expr = matched "dsl-not";
      expected = [ "beta/dsl-not" ];
    };
    "test-dsl-or" = {
      expr = matched "dsl-or";
      expected = [
        "gamma/dsl-or"
        "leaf/dsl-or"
        "sidecar/dsl-or"
      ];
    };
    "test-dsl-class" = {
      expr = matched "dsl-class";
      expected = [
        "alpha/dsl-class"
        "beta/dsl-class"
        "gamma/dsl-class"
        "leaf/dsl-class"
        "sidecar/dsl-class"
      ];
    };
    "test-dsl-child" = {
      expr = matched "dsl-child";
      expected = [ "sidecar/dsl-child" ];
    };
    "test-dsl-descendant" = {
      expr = matched "dsl-descendant";
      expected = [ "leaf/dsl-descendant" ];
    };
    # A list-of-selectors `is` is an AND, and demonstrates cross-file merge:
    # this label rule lives in rules-dsl.nix yet coexists with rules.nix's list.
    "test-list-and" = {
      expr = matched "list-and";
      expected = [
        "alpha/list-and"
        "gamma/list-and"
        "leaf/list-and"
        "sidecar/list-and"
      ];
    };

    # ── select.* graph traversal (computed inside the demo class) ──
    # select.parentNode — direct parent (null at a root).
    "test-parent" = {
      expr = [
        (has "alpha/parent=root")
        (has "sidecar/parent=alpha")
        (has "leaf/parent=gamma")
      ];
      expected = [
        true
        true
        true
      ];
    };
    # select.children — direct children matching a selector.
    "test-children" = {
      expr = [
        (has "alpha/child=sidecar")
        (has "gamma/child=leaf")
      ];
      expected = [
        true
        true
      ];
    };
    # select.siblings — same-parent nodes (roots are siblings of each other).
    "test-siblings" = {
      expr = builtins.filter (lib.hasInfix "/sibling=") allTags;
      expected = [
        "alpha/sibling=beta"
        "alpha/sibling=gamma"
        "beta/sibling=alpha"
        "beta/sibling=gamma"
        "gamma/sibling=alpha"
        "gamma/sibling=beta"
      ];
    };
    # select.within — descendants of a node.
    "test-descendants" = {
      expr = [
        (has "alpha/desc=sidecar")
        (has "gamma/desc=leaf")
      ];
      expected = [
        true
        true
      ];
    };
    # select.parents — ancestors of a node.
    "test-ancestors" = {
      expr = [
        (has "sidecar/anc=alpha")
        (has "leaf/anc=gamma")
      ];
      expected = [
        true
        true
      ];
    };
  };
}
