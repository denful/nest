{
  outputs = _: {
    lib = import ./.;
    module = ./module.nix;
    flakeModule = ./module.nix;
    flakeModules.default = ./module.nix;
    modules.flake.default = ./module.nix;
  };
}
