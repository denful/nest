# Exposes nest's evalResult.byClass.terranix as flake.packages.x86_64-linux.
# byClass.terranix = { web-1 = <drv>; web-2 = <drv>; } — one config per node.
{
  config,
  lib,
  inputs,
  ...
}:
let
  result = config.flake.nest.evalResult;
  terranixPkgs = result.byClass.terranix or { }; # terranix derivations by node name
in
{
  imports = [ inputs.nest.flakeModule ];

  options.flake.packages = lib.mkOption {
    default = { };
    type = lib.types.attrs;
  };
  options.flake.tests = lib.mkOption { };

  config.flake.packages.x86_64-linux = terranixPkgs;
  config.flake.tests = {
    "test-servers-in-terranix" = {
      expr = result.byClass ? terranix;
      expected = true;
    };
    "test-web-1-has-config" = {
      expr = terranixPkgs ? web-1;
      expected = true;
    };
    "test-both-servers" = {
      expr = builtins.length (builtins.attrNames terranixPkgs);
      expected = 2;
    };
  };
}
