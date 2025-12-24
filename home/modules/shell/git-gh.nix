{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Maltina Basse";
        email = "maltinabasse@gmail.com";
      };
    };
    extraConfig = {
      safe.directory = "/etc/nixos";
      core.editor = "nvim"; # We didn't cover this, but I trust you can setup neovim on your own, perhaps via nixvim ;3 (https://nix-community.github.io/nixvim/)
    };
  };
  programs.gh = {
    enable = true;
  };
}

