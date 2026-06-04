# vim trait: class.nvf produces a neovim PACKAGE, not a NixOS system.
# This is the key difference from the host trait in fleet-demo/default:
#   host.class.nixos → nixosSystem (a full system closure)
#   vim.class.nvf    → neovimConfiguration(...).neovim (a single package)
# nest is target-agnostic; the class fn determines what the output is.
{ inputs, ... }:
{
  # node.system inherited from namespace (dom.nix nest.neovim.system).
  # modules = list of nvf module attrsets collected from matching rules.
  nest.trait.vim.class.nvf =
    { node, ... }:
    modules:
    (inputs.nvf.lib.neovimConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${node.system};
      inherit modules;
    }).neovim;
}
