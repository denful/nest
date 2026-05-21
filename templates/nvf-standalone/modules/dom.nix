{ nest, ... }:
{
  nest.neovim.system = "x86_64-linux";

  nest.neovim.minimal = {
    is = [ nest.vim ];
  };

  nest.neovim.full = {
    is = [ nest.vim ];
    enableLSP = true;
  };
}
