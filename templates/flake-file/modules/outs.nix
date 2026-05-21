{
  config,
  inputs,
  lib,
  ...
}:
let
  result = config.flake.nest.evalResult;
  flakeInputCfgs = result.byClass.flakeInput or { };
in
{
  imports = [
    inputs.flake-file.flakeModules.flake
    inputs.nest.flakeModules.default
    { options.flake.packages = lib.mkOption { }; }
    { options.flake.tests = lib.mkOption { }; }
  ];

  flake.packages.x86_64-linux.write-flake = config.flake-file.apps.write-flake inputs.nixpkgs.legacyPackages.x86_64-linux;

  flake-file.inputs = flakeInputCfgs;

  flake.tests = {
    "test-flakeInput-class-exists" = {
      expr = result.byClass ? flakeInput;
      expected = true;
    };
    "test-nest-input-exists" = {
      expr = flakeInputCfgs ? nest;
      expected = true;
    };
    "test-nixpkgs-input-exists" = {
      expr = flakeInputCfgs ? nixpkgs;
      expected = true;
    };
    "test-import-tree-has-url" = {
      expr = flakeInputCfgs.import-tree ? url;
      expected = true;
    };
    "test-flake-file-exists" = {
      expr = flakeInputCfgs ? flake-file;
      expected = true;
    };
  };
}
