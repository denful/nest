inputs:
(inputs.nixpkgs.lib.evalModules {
  specialArgs.inputs = inputs;
  modules = [ (inputs.import-tree ./modules) ];
}).config.flake
