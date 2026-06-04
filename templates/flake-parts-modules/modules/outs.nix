# flake-parts module: wires nest's byClass.devshell into perSystem.devshells.
{
  config,
  inputs,
  ...
}:
let
  result = config.flake.nest.evalResult;
  devshellCfgs = result.byClass.devshell or { }; # keyed by node name, e.g. { default = {...}; }
in
{
  imports = [
    inputs.nest.flakeModule
    inputs.devshell.flakeModule
  ];

  systems = [ "x86_64-linux" ];

  perSystem.devshells = devshellCfgs;

  flake.tests = {
    "test-devshell-class-exists" = {
      expr = result.byClass ? devshell;
      expected = true;
    };
    "test-default-shell-exists" = {
      expr = devshellCfgs ? default;
      expected = true;
    };
    "test-hello-in-default-devshell" = {
      expr = builtins.any (
        c: (c.package.pname or "") == "hello"
      ) config.flake.devShells.x86_64-linux.default.config.commands;
      expected = true;
    };
  };
}
