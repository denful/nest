{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.nest.flakeModule ];

  options.flake.nixosConfigurations = lib.mkOption { };
  config.flake.nixosConfigurations = config.flake.nest.evalResult.byClass.nixos or { };

  options.flake.tests = lib.mkOption { };
  config.flake.tests = {
    smoke.test-it-works = {
      expr = 22;
      expected = 22;
    };
  };
}
