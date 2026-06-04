# ════════════════════════════════════════════════════════════
# nest template — NOFLAKE
#
# Demonstrates: same single-host NixOS config as `minimal`,
#   but driven by plain Nix + npins instead of flakes.
#   npins pins inputs to exact revisions in sources.json —
#   reproducible without the flake evaluator or flake.lock.
# Pick this when: you want reproducible inputs but not flakes
# Read order: default.nix → with-inputs.nix → follows.nix
#             → outputs.nix → modules/ (mirrors minimal/)
# See also: ../minimal (flake version of this config),
#           ../default (flake + users + home-manager)
# ════════════════════════════════════════════════════════════
{
  # All three components are overridable for testing or local dev.
  with-inputs ? import ./with-inputs.nix, # fetches pinned sources via npins
  follows ? ./follows.nix, # optional input overrides (empty by default)
  outputs ? ./outputs.nix, # the actual nest evaluation (mirrors flake outputs)
  ...
}:
# `with-inputs` wires npins sources → passes them as `inputs` to `outputs`.
# This is the non-flake equivalent of a flake's `inputs` + `outputs` fields.
with-inputs follows outputs
