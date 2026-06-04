# Same as minimal/modules/outs.nix — nest's flakeModule works with npins inputs too.
{
  config,
  lib,
  inputs,
  ...
}:
let
  nixosCfgs = config.flake.nest.evalResult.byClass.nixos or { };
  nixosNames = builtins.attrNames nixosCfgs;
in
{
  imports = [ inputs.nest.flakeModule ]; # nest module still works; no flake needed
  options.flake.nixosConfigurations = lib.mkOption { };
  options.flake.tests = lib.mkOption { };
  config.flake.nixosConfigurations = nixosCfgs;
  config.flake.tests = {
    "test-igloo-in-nixos" = {
      expr = nixosNames;
      expected = [ "igloo" ];
    };
    "test-no-extra-hosts" = {
      expr = builtins.length nixosNames;
      expected = 1;
    };
  };
}
