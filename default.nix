let
  readDirImports =
    dir:
    let
      files = builtins.readDir dir;
      fileList = builtins.filter (name: builtins.match ".*\\.nix$" name != null) (
        builtins.attrNames files
      );
      imports = builtins.map (name: import (dir + "/${name}") nest) fileList;
    in
    builtins.foldl' (acc: val: acc // val) { } imports;

  nest = readDirImports ./nix;
in
nest
