{
  description = "NVF standalone: neovim configs as nest nodes";

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
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
  };
}
