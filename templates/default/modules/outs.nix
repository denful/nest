# This file provides flake-level outputs.
# Since this example is simple it does not uses flake-parts.
# So it defines its own simple flake.* options for outputs.
# Remove the option definitions if you use flake-parts or other
# module system.
#
{
  config,
  lib,
  inputs,
  ...
}:
let
  result = config.flake.nest.evalResult;
in
{
  imports = [ inputs.nest.flakeModule ];

  options.flake.nixosConfigurations = lib.mkOption { };
  options.flake.homeConfigurations = lib.mkOption { };

  config.flake.nixosConfigurations = result.byClass.nixos or { };
  config.flake.homeConfigurations = result.byClass.homeManager or { };
}
