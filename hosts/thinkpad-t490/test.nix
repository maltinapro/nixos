{ pkgs, ... }:

{
  networking.hostName = "t490-test";
  
  # Desktop Environment: XFCE
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  # Test and Analysis Tools
  environment.systemPackages = with pkgs; [
    google-chrome
    curl
    wget
    strace 
    perf   
    wireshark 
    brave
  ];
  
  # Networking and Security
  networking.firewall.enable = true;
  
  # Automatic Garbage Collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
}
