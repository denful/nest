# Exposes nest's evaluated results as flake outputs and wires up template tests.
{
  config,
  lib,
  inputs,
  ...
}:
let
  # `byClass.nixos` is where traits.nix deposited each built NixOS system.
  # If no host node exists this gracefully returns {} rather than erroring.
  nixosCfgs = config.flake.nest.evalResult.byClass.nixos or { };
  nixosNames = builtins.attrNames nixosCfgs;
in
{
  imports = [ inputs.nest.flakeModule ]; # registers nest's flake-parts module

  options.flake.nixosConfigurations = lib.mkOption { };
  options.flake.tests = lib.mkOption { };

  config.flake.nixosConfigurations = nixosCfgs; # standard flake output shape
  config.flake.tests = {
    # Sanity-check: template self-tests confirm igloo arrived in nixos class.
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
