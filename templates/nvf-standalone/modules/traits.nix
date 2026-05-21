{ inputs, ... }:
{
  nest.trait.vim.class.nvf =
    { node, ... }:
    modules:
    (inputs.nvf.lib.neovimConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${node.system};
      inherit modules;
    }).neovim;
}
