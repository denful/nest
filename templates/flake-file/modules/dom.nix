{ nest, ... }:
{
  nest.deps = {
    import-tree = {
      is = [ nest.dep ];
      url = "github:vic/import-tree";
    };

    nixpkgs = {
      is = [ nest.dep ];
      url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    };

    flake-file = {
      is = [ nest.dep ];
      url = "github:vic/flake-file";
    };

    nest = {
      is = [ nest.dep ];
      url = "github:vic/nest";
    };
  };

}
