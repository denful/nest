# Receives resolved `inputs` from with-inputs and runs the nest evaluation.
# Mirrors flake.nix `outputs` from minimal/ — proof that flakes are optional.
inputs:
(inputs.nixpkgs.lib.evalModules {
  specialArgs.inputs = inputs; # makes `inputs` available in every module
  modules = [ (inputs.import-tree ./modules) ]; # same modules/ as minimal
}).config.flake
