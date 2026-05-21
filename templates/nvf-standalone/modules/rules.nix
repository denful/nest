{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.vim;
      nvf = {
        vim.viAlias = true;
        vim.vimAlias = true;
        vim.theme.enable = true;
      };
    }
    {
      is = [
        nest.vim
        (nest.not (nest.attrs { enableLSP = true; }))
      ];
      nvf = {
        vim.theme.style = "night";
        vim.theme.name = "dracula";
      };
    }
    {
      is = [
        nest.vim
        (nest.attrs { enableLSP = true; })
      ];
      nvf = {
        vim.lsp.enable = true;
        vim.languages.nix.enable = true;
        vim.theme.style = "latte";
        vim.theme.name = "catppuccin";
      };
    }
  ];
}
