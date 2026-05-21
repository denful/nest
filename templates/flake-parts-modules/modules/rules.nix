{ nest, ... }:
{
  nest.rules = [
    {
      is = nest.shell;
      devshell =
        { select, ... }:
        {
          commands = [
            { package = select.node.pkgs.hello; }
          ];
        };
    }
  ];
}
