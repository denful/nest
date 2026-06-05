help:
  just -l

docs:
  cd docs && pnpm run dev

docs-build:
  cd docs && pnpm run build

fmt *args:
  deadnix --edit
  statix fix
  treefmt {{args}}

update-nest:
  fd flake.nix ./templates --exec nix flake update nest --flake {//}

ci:
  deadnix --fail
  statix check
  just fmt --ci --no-cache
  just test
  just check default
  just check minimal
  just check fleet-demo
  just check selectors-demo
  just check flake-parts-modules
  just check flake-file
  just check-noflake

check-noflake:
  cd templates/noflake && nix-build . --no-link --arg follows '{ nest.outPath = ./../..; }'  -A nixosConfigurations.igloo.config.warnings

check template *args:
  nix flake check ./templates/{{template}} --override-input nest . {{args}}
  nix-unit --override-input nest . --flake ./templates/{{template}}#tests {{args}}

test suite="all" *args:
  nix-unit --expr 'let x = import ./tests.nix; in if "{{suite}}" == "all" then x else x.{{suite}}' {{args}}

