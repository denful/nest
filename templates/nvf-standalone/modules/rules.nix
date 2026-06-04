# Rules: attr-based config branching via not() + attrs() selectors.
#
# Three-layer approach:
#   1. base rule   — fires on ALL vim nodes (shared defaults)
#   2. no-LSP rule — fires when enableLSP attr is ABSENT or false
#   3. LSP rule    — fires when enableLSP = true
#
# nest.not(nest.attrs {...}) = "node does NOT have this attr value".
# Both branch rules can coexist; the selector decides which applies.
{ nest, ... }:
{
  nest.rules = [
    # Base config: applies to every vim node regardless of attrs.
    {
      is = nest.vim;
      nvf = {
        vim.viAlias = true;
        vim.vimAlias = true;
        vim.theme.enable = true;
      };
    }

    # Branch A: node lacks enableLSP = true → lighter theme, no LSP.
    # nest.not(nest.attrs {...}) excludes nodes where the attr matches.
    {
      is = [
        nest.vim
        (nest.not (nest.attrs { enableLSP = true; })) # no enableLSP attr
      ];
      nvf = {
        vim.theme.style = "night";
        vim.theme.name = "dracula";
      };
    }

    # Branch B: node has enableLSP = true → LSP + different theme.
    # nest.attrs matches nodes where that attr equals the given value.
    {
      is = [
        nest.vim
        (nest.attrs { enableLSP = true; }) # attr selector
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
