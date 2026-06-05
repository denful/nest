# Rule/selector cfg FUNCTIONS get their arguments injected by NAME. nest resolves
# what it can from the matched node's context (the node itself, `select`, entity
# traits, parents); any argument it cannot resolve — e.g. `pkgs`/`lib`/`config` —
# is DEFERRED: callWithArgs returns a functor carrying the still-needed args, so
# the module system can supply them later at evaluation time. These tests pin
# that contract (it backs the `pkgs`/`lib` arguments used in the rules guides).
nest:
let
  inherit (nest) callWithArgs makeNode emptyCtx;
  node = makeNode "n" [ ] { };
  ctx = emptyCtx node [ node ];
  # `pkgs` is not a node/select/entity arg, so nest cannot resolve it now.
  fn = { pkgs, ... }: pkgs.hello;
  deferred = callWithArgs fn node ctx;
in
{
  deferral = {
    # the unresolved arg is carried on the returned functor, not lost.
    test-defers-unresolved-arg = {
      expr = deferred ? __functionArgs && deferred.__functionArgs ? pkgs;
      expected = true;
    };
    # applying the functor later (as the module system does) completes the call.
    test-deferred-resolves = {
      expr = deferred {
        pkgs = {
          hello = "ok";
        };
      };
      expected = "ok";
    };
    # an arg nest CAN resolve (the node) is injected immediately — no deferral.
    test-resolved-arg-immediate = {
      expr = callWithArgs ({ node, ... }: node.name) node ctx;
      expected = "n";
    };
  };
}
