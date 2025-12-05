{ pkgs, ... }:

{
  system.nixos.label = "development";
  networking.hostName = "t490-dev";
  
  # Desktop Environment: XFCE (Consistent with your preference)
  services.xserver.enable = true;
  # Use XFCE desktop manager and display manager (LightDM is common)
  services.xserver.desktopManager.xfce.enable = true; 
  services.xserver.displayManager.lightdm.enable = true;

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
