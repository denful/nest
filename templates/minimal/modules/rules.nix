# Rules: CSS-selector-like patterns that inject NixOS config into matching nodes.
{ nest, ... }:
{
  nest.rules = [
    {
      # `is = nest.host` selects every node carrying the host trait —
      # equivalent to the CSS class selector `.host`.
      # No per-host repetition: one rule covers all hosts automatically.
      is = nest.host;
      nixos = {
        # Minimal boot config so nixosSystem evaluates without real hardware.
        boot.loader.grub.enable = false;
        fileSystems."/".device = "/dev/null";
        fileSystems."/".fsType = "auto";
      };
    }
  ];
}
