# Entry point: evaluates all modules under ./modules and exposes .flake outputs.
inputs:
(inputs.nixpkgs.lib.evalModules {
  specialArgs.inputs = inputs;
  modules = [ (inputs.import-tree ./modules) ];
}).config.flake
