# ════════════════════════════════════════════════════════════
# nest template — NVF-STANDALONE
#
# Demonstrates: driving a NON-NixOS tool (neovim via nvf) with nest;
#   custom `vim` trait whose class outputs a package, not a system;
#   not() + attrs() selectors for attr-based config branching
#   (enableLSP = true/false chooses theme + LSP config).
# Pick this when: producing per-tool packages instead of NixOS systems.
# Read order: dom.nix → traits.nix → rules.nix → outs.nix
# See also: ../terranix-demo (another non-NixOS target, IaC flavour),
#           ../default (NixOS output for comparison)
# ════════════════════════════════════════════════════════════
{ nest, ... }:
{
  # neovim is a NAMESPACE wrapper — not a node. Provides system to children.
  nest.neovim.system = "x86_64-linux";

  # minimal: vim trait, no extra attrs → rules will NOT apply LSP config.
  nest.neovim.minimal = {
    is = [ nest.vim ];
  };

  # full: enableLSP = true triggers the attr selector in rules.nix.
  # Attrs on nodes are plain Nix values — selectors can match them.
  nest.neovim.full = {
    is = [ nest.vim ];
    enableLSP = true; # attr selector key — see rules.nix
  };
}
