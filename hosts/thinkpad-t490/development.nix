{ pkgs, ... }:

{
  system.nixos.label = "development";
  networking.hostName = "maltinas-thinkpad-t490-dev";
  
  # Development Tools and Environments
  environment.systemPackages = with pkgs; [
    google-chrome
    git
    neovim 
    vscode
    nodejs
    python3
    go
    rustup
    tmux
    htop
    dbeaver-bin
  ];
  
  # Docker and Virtualization
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "user" ];
}
