{
  config,
  lib,
  inputs,
  ...
}:
let
  result = config.flake.nest.evalResult;
  nvfPkgs = result.byClass.nvf or { };
in
{
  imports = [ inputs.nest.flakeModule ];

  options.flake.packages = lib.mkOption {
    default = { };
    type = lib.types.attrs;
  };
  options.flake.tests = lib.mkOption { };

  config.flake.packages.x86_64-linux = nvfPkgs;
  config.flake.tests = {
    "test-nvf-class-exists" = {
      expr = result.byClass ? nvf;
      expected = true;
    };
    "test-neovim-packages-count" = {
      expr = builtins.length (builtins.attrNames nvfPkgs);
      expected = 2;
    };
  };
}
