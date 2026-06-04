# Rules: single rule fires on all server nodes.
# `node` is auto-injected — carries name, serverType, region from dom.nix.
# Each node produces its own terraform resource block, keyed by node.name.
# provider/variable blocks repeat per node but terranix merges them (idempotent).
{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.server;
      # `node` arg: injected automatically when rule fn declares it.
      # node.name = "web-1" or "web-2" (DOM key), used as resource name.
      # node.serverType / node.region = per-node attrs from dom.nix.
      terranix =
        { node, ... }:
        {
          terraform.required_providers.hcloud = {
            source = "hetznercloud/hcloud";
            version = "~> 1.0";
          };
          variable.hcloud_token = {
            type = "string";
            sensitive = true;
          };
          provider.hcloud.token = "\${var.hcloud_token}";
          # resource block name = node.name → web-1 and web-2 each get their own.
          resource.hcloud_server.${node.name} = {
            inherit (node) name;
            server_type = node.serverType; # cx11 or cx21 from dom.nix
            location = node.region; # nbg1 or fsn1 from dom.nix
            image = "debian-12";
          };
        };
    }
  ];
}
