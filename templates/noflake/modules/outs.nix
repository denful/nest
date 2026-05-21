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
  imports = [ inputs.nest.flakeModule ];

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
