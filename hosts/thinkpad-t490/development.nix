{ pkgs, ... }:

{
  system.nixos.label = "development";
  networking.hostName = "maltinas-thinkpad-t490-dev";
  
  # Development Tools and Environments
  environment.systemPackages = with pkgs; [
    google-chrome
    git
    neovim
    nodejs
    python3
    go
    tmux
    htop
    dbeaver-bin
    #rust
    rustc
    cargo
    rustlings
    rust-analyzer
    gcc
  ];
  
  # Docker and Virtualization
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "user" ];
}
