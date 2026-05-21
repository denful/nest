{
  description = "Minimal nest setup: one host, nixos class";

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      specialArgs.inputs = inputs;
      modules = [ (inputs.import-tree ./modules) ];
    }).config.flake;

  inputs = {
    nest.url = "github:vic/nest";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
