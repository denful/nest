{
  description = "Fleet demo: multi-env topology with haproxy, nginx, and select-based cross-host config";

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      specialArgs.inputs = inputs;
      modules = [
        (inputs.import-tree ./modules)
      ];
    }).config.flake;

  inputs = {
    nest.url = "github:vic/nest";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
