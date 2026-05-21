let
  nest = import ./.;
  testUtils = import ./tests/test-utils.nix nest;

  # Import all .nix files from tests/ directory
  readDirImports =
    dir:
    let
      files = builtins.readDir dir;
      fileList = builtins.filter (name: builtins.match ".*\\.nix$" name != null) (
        builtins.attrNames files
      );
      imports = builtins.map (name: import (dir + "/${name}") (nest // testUtils)) fileList;
    in
    builtins.foldl' (acc: val: acc // val) { } imports;
in
{
  nix-unit = readDirImports ./tests;
}
