{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.server;
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
          resource.hcloud_server.${node.name} = {
            inherit (node) name;
            server_type = node.serverType;
            location = node.region;
            image = "debian-12";
          };
        };
    }
  ];
}
