# Each rule tags the nodes it selects "<node>/<feature>". The feature names the
# selector FORM, so the self-tests can prove exactly which nodes that form
# matched. `tag` is a cfg FUNCTION: nest injects the matched `node` by name.
#
# nest list-form rules cannot be split across import-tree files (only the last
# file would win), so every string/DSL selector lives in this one list. The
# label-keyed rules in rules-dsl.nix use a different form that DOES merge.
{ nest, ... }:
let
  tag = feature: { node, ... }: "${node.name}/${feature}";
in
{
  nest.rules = [
    # ── simple forms ────────────────────────────────────────────
    # `*` — universal: every node.
    {
      is = "*";
      demo = tag "all";
    }
    # `#id` — node by name.
    {
      is = "#gamma";
      demo = tag "id";
    }
    # `[attr=val]` compound (`box[kind=db]`): trait AND attribute.
    {
      is = "box[kind=db]";
      demo = tag "attr-eq";
    }
    # `[attr=true]` — boolean-aware attribute.
    {
      is = "box[active=true]";
      demo = tag "bool";
    }
    # `[attr]` — attribute existence.
    {
      is = "box[pinned]";
      demo = tag "attr-exists";
    }

    # ── combinators ─────────────────────────────────────────────
    # ` ` descendant: a box anywhere under #gamma → leaf.
    {
      is = "#gamma box";
      demo = tag "descendant";
    }
    # `>` child: a box that is a DIRECT child of #alpha → sidecar.
    {
      is = "#alpha > box";
      demo = tag "child";
    }
    # `+` adjacent sibling: the node right after #alpha → beta.
    {
      is = "#alpha + #beta";
      demo = tag "adjacent";
    }
    # `,` group / or: alpha OR beta.
    {
      is = "#alpha, #beta";
      demo = tag "group";
    }
    # `&` current/relative: a node that HAS a direct box child → alpha, gamma.
    {
      is = "& > box";
      demo = tag "current-child";
    }

    # ── pseudo-classes ──────────────────────────────────────────
    # `:has` — a box with a cache-kind descendant → alpha, gamma.
    {
      is = "box:has([kind=cache])";
      demo = tag "has";
    }
    # `:not` — a box that is not env=prod → beta (the only non-prod).
    {
      is = "box:not([env=prod])";
      demo = tag "not";
    }
    # `:is(…)` — a box that is #beta OR #gamma. Inside a pseudo, list the
    # alternatives with NO comma (a comma would split the selector at the top
    # level, before parens are considered). For top-level OR, use `,` instead.
    {
      is = "box:is(#beta#gamma)";
      demo = tag "is-pseudo";
    }
    # `:within` — a box inside the #gamma subtree → leaf.
    {
      is = "box:within(#gamma)";
      demo = tag "within";
    }

    # ── predicate selector ──────────────────────────────────────
    # `nest.when` — match by an ARBITRARY Nix predicate over the node.
    {
      is = nest.when ({ node, ... }: (node.kind or "") == "db");
      demo = tag "when";
    }
  ];
}
