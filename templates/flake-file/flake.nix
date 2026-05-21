# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    nest.url = "github:vic/nest";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
