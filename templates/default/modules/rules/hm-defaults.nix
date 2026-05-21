{
  # Anything producing class homeManager, standalone or hosted
  nest.rules.".homeManager" = {
    homeManager =
      { node, ... }:
      {
        home.stateVersion = "25.11";
        home.username = node.name;
        home.homeDirectory = "/home/${node.name}";
      };
  };
}
